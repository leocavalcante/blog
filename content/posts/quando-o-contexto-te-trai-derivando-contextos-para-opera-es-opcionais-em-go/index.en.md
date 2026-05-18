---
title: 'When Context Betrays You: Deriving Contexts for Optional Operations in Go'
description: 'In Go, context.Context is the standard mechanism for propagating cancellation, deadlines, and values across Goroutines and function calls. But passing context forward has a subtle trap.'
date: "2026-05-18T10:00:00-03:00"
updated: ""
draft: false
tags: []
url: /en/quando-o-contexto-te-trai-derivando-contextos-para-opera-es-opcionais-em-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

In Go, `context.Context` is the standard mechanism for propagating cancellation, *deadlines*, and values across Goroutines and function calls. The general rule is simple: always pass the context forward. But this rule has a subtle trap that can cause bugs that are hard to reproduce, especially when you have optional operations with fallback.

## The scenario

Imagine a function that needs to:

1.  Perform a main operation (required).

2.  Call a slow external service to enrich the result (optional, has a fallback if it fails).

3.  Use the enriched result (or the fallback) in another main operation.


In code, it looks like this:

```go
func (s *Service) Process(ctx context.Context, input Input) (Result, error) {
    // Operação principal
    base, err := s.repo.Get(ctx, input.ID)
    if err != nil {
        return Result{}, fmt.Errorf("getting base: %w", err)
    }

    // Operação opcional — tem fallback se falhar
    description := fallbackDescription
    enriched, err := s.aiClient.Enrich(ctx, base) // <-- usando o ctx do pai
    if err == nil {
        description = enriched.Description
    }

    // Outra operação principal — usa o resultado da operação opcional
    result, err := s.repo.Save(ctx, base, description)
    if err != nil {
        return Result{}, fmt.Errorf("saving result: %w", err) // <-- erro aqui?
    }

    return result, nil
}
```

At first glance, the code looks correct, but there is a silent bug waiting to surface.

## The problem

The call to `aiClient.Enrich` uses the same `ctx` from the *caller*. If that context is canceled or expires *during* the call to the external service, the returned error is "set aside" by `if err == nil`; after all, the fallback exists exactly for that.

The problem: **the context is already canceled**. And the code keeps running as if nothing had happened.

When `s.repo.Save(ctx, ...)` is called right after, the context is already dead. The call fails immediately with `context canceled`, and now the error has *no* fallback. It is a fatal error that bubbles up to the *caller*.

```plaintext
ERRO: saving result: context canceled
```

What makes this bug particularly treacherous:

*   **It is intermittent**: it only happens when the context expires during the optional call.

*   **The error points to the wrong place**: the log blames `saving result`, not the optional call.

*   **It seems impossible**: `s.repo.Save` may be a trivial and fast operation, but still fails.


## Visualizing the timeline

```plaintext
t=0ms   Process() começa, ctx tem deadline em t=500ms
t=10ms  repo.Get() → OK
t=100ms aiClient.Enrich() começa (operação lenta)
t=500ms DEADLINE ATINGIDO — ctx é cancelado
t=520ms aiClient.Enrich() retorna erro (context canceled) → swallowed
t=520ms repo.Save(ctx, ...) → falha imediatamente (context canceled)
```

`Save` takes less than 1ms, but still fails because the context is already canceled before the call even starts.

## The solution: context.WithoutCancel

Starting with Go 1.21, the standard library offers `context.WithoutCancel`:

```go
func WithoutCancel(parent Context) Context
```

It creates a child context that **inherits the parent's values** (tracing, authentication, etc.), but **does not inherit cancellation or the deadline**. That is exactly what we need for optional operations.

```go
func (s *Service) Process(ctx context.Context, input Input) (Result, error) {
    base, err := s.repo.Get(ctx, input.ID)
    if err != nil {
        return Result{}, fmt.Errorf("getting base: %w", err)
    }

    // Contexto independente para a operação opcional
    enrichCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
    defer cancel()

    description := fallbackDescription
    enriched, err := s.aiClient.Enrich(enrichCtx, base)
    if err == nil {
        description = enriched.Description
    }

    // ctx ainda pode estar válido aqui
    result, err := s.repo.Save(ctx, base, description)
    if err != nil {
        return Result{}, fmt.Errorf("saving result: %w", err)
    }

    return result, nil
}
```

Now:

*   `aiClient.Enrich` has its own independent timeout (5 seconds).

*   If the parent context expires during `Enrich`, the optional operation fails and uses the fallback, as expected.

*   The parent context, if still valid, is used for `repo.Save`. If it has already expired, the error is now honest and expected.

*   If the parent context expires before `Enrich` finishes, `repo.Save` will also fail, but that is the correct behavior: the caller canceled the operation, and we should not persist anything.


## Why not simply use context.Background()?

A common alternative is to use `context.Background()` for the optional operation:

```go
enrichCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

This works for the cancellation problem, but **loses the parent context values**, such as trace IDs, observability spans, propagated authentication credentials, etc.

```go
// Com context.Background() — trace ID perdido
enrichCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

// Com context.WithoutCancel — trace ID preservado
enrichCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
```

Use `context.WithoutCancel` when you want cancellation isolation without giving up traceability.

## Complete example: optional notification

Here is a more concrete example of an HTTP handler that sends an optional notification after creating a resource:

```go
func (h *Handler) CreateOrder(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context() // deadline atrelado ao request HTTP

    var order Order
    if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
        http.Error(w, "invalid body", http.StatusBadRequest)
        return
    }

    created, err := h.store.CreateOrder(ctx, order)
    if err != nil {
        http.Error(w, "internal error", http.StatusInternalServerError)
        return
    }

    // Notificação por e-mail é opcional — não deve bloquear a resposta
    // nem falhar por culpa do contexto do request
    go func() {
        notifCtx, cancel := context.WithTimeout(
            context.WithoutCancel(ctx), // herda trace ID, não herda deadline
            10*time.Second,
        )
        defer cancel()

        if err := h.mailer.SendConfirmation(notifCtx, created); err != nil {
            slog.ErrorContext(notifCtx, "sending order confirmation", "err", err)
        }
    }()

    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(created)
}
```

## Complete example: AI content generation

Another common pattern is using AI to generate content with a fallback to static text:

```go
const (
    aiTimeout       = 10 * time.Second
    fallbackSummary = "Resumo não disponível."
)

func (s *Service) PublishArticle(ctx context.Context, article Article) (string, error) {
    // Tentativa de gerar resumo com IA — operação opcional
    summary := fallbackSummary

    aiCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), aiTimeout)
    defer cancel()

    generated, err := s.ai.Summarize(aiCtx, article.Body)
    if err != nil {
        slog.WarnContext(ctx, "ai summary failed, using fallback", "err", err)
    } else {
        summary = generated
    }

    // Publicação é obrigatória — usa o ctx original
    id, err := s.publisher.Publish(ctx, article, summary)
    if err != nil {
        return "", fmt.Errorf("publishing article: %w", err)
    }

    return id, nil
}
```

## Checklist: when to use context.WithoutCancel

Use `context.WithoutCancel` when **all** of these conditions are true:

*   The operation is **optional**, and there is a fallback if it fails.

*   The operation's error is **intentionally swallowed** (or only logged).

*   After the optional operation, there are **other required operations** that will still use the parent context.

*   You want to **preserve the context values** (trace, auth, etc.).


If the operation is required (no fallback), do not use `WithoutCancel`; let cancellation propagate normally.

## Summary

| Situation | Approach |
| --- | --- |
| Required operation | Pass `ctx` directly |
| Optional operation, no traceability needed | `context.WithTimeout(context.Background(), d)` |
| Optional operation, with traceability | `context.WithTimeout(context.WithoutCancel(ctx), d)` |
| Long-running background Goroutine | Create a root context with `context.Background()` |

The bug described here is easy to introduce and hard to diagnose because the error appears somewhere different from where the context was canceled. The general rule is: **if you are swallowing a context error, check whether the context you are swallowing is the same one that will be used in the next calls**.

`context.WithoutCancel` is the right tool for separating the lifecycle of optional operations from the lifecycle of the main request, without losing traceability.
