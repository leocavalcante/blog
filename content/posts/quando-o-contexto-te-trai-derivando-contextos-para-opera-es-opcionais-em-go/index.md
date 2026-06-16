---
title: 'Quando o contexto te trai: derivando contextos para operações opcionais em Go'
description: 'Em Go, o context.Context é o mecanismo padrão para propagar cancelamento, deadlines e valores entre Goroutines e chamadas de função. A regra geral é simples: sempre passe o contexto para frente. Mas e'
date: "2026-05-18T10:00:00-03:00"
updated: ""
draft: false
tags:
    - go
    - context
    - concurrency
    - best-practices
    - debugging
url: /quando-o-contexto-te-trai-derivando-contextos-para-opera-es-opcionais-em-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Em Go, o `context.Context` é o mecanismo padrão para propagar cancelamento, *deadlines* e valores entre Goroutines e chamadas de função. A regra geral é simples: sempre passe o contexto para frente. Mas essa regra tem uma armadilha sutil que pode causar bugs difíceis de reproduzir, especialmente quando você tem operações opcionais com fallback.

## O cenário

Imagine uma função que precisa:

1.  Fazer uma operação principal (obrigatória).

2.  Chamar um serviço externo lento para enriquecer o resultado (opcional, tem um fallback se falhar).

3.  Usar o resultado enriquecido (ou o fallback) em outra operação principal.


Em código, isso se parece com:

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

O código parece correto à primeira vista, mas há um bug silencioso esperando para se manifestar.

## O problema

A chamada ao `aiClient.Enrich` usa o mesmo `ctx` do *caller*. Se esse contexto for cancelado ou expirar *durante* a chamada ao serviço externo, o erro retornado é "deixado de lado" pelo `if err == nil`, afinal, o fallback existe exatamente para isso.

O problema: **o contexto já está cancelado**. E o código continua executando como se nada tivesse acontecido.

Quando `s.repo.Save(ctx, ...)` é chamado logo depois, o contexto já está morto. A chamada falha imediatamente com `context canceled`, e agora o erro *não* tem fallback. É um erro fatal que sobe para o *caller*.

```plaintext
ERRO: saving result: context canceled
```

O que torna esse bug particularmente traiçoeiro:

*   **É intermitente**: só ocorre quando o contexto expira durante a chamada opcional.

*   **O erro aponta para o lugar errado**: o log acusa `saving result`, não a chamada opcional.

*   **Parece impossível**: `s.repo.Save` pode ser uma operação trivial e rápida, mas ainda assim falha.


## Visualizando a linha do tempo

```plaintext
t=0ms   Process() começa, ctx tem deadline em t=500ms
t=10ms  repo.Get() → OK
t=100ms aiClient.Enrich() começa (operação lenta)
t=500ms DEADLINE ATINGIDO — ctx é cancelado
t=520ms aiClient.Enrich() retorna erro (context canceled) → swallowed
t=520ms repo.Save(ctx, ...) → falha imediatamente (context canceled)
```

O `Save` leva menos de 1ms, mas ainda assim falha porque o contexto já está cancelado antes mesmo de a chamada começar.

## A solução: context.WithoutCancel

A partir do Go 1.21, a biblioteca padrão oferece `context.WithoutCancel`:

```go
func WithoutCancel(parent Context) Context
```

Ele cria um contexto filho que **herda os valores do pai** (tracing, autenticação, etc.), mas **não herda o cancelamento nem o deadline**. É exatamente o que precisamos para operações opcionais.

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

Agora:

*   `aiClient.Enrich` tem seu próprio timeout independente (5 segundos).

*   Se o contexto do pai expirar durante o `Enrich`, a operação opcional falha e usa o fallback, como esperado.

*   O contexto do pai, se ainda válido, é usado para `repo.Save`. Se já expirou, o erro agora é honesto e esperado.

*   Se o contexto do pai expirar antes do `Enrich` terminar, `repo.Save` também falhará, mas isso é o comportamento correto: o chamador cancelou a operação, não devemos persistir nada.


## Por que não simplesmente usar context.Background()?

Uma alternativa comum é usar `context.Background()` para a operação opcional:

```go
enrichCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
```

Isso funciona para o problema de cancelamento, mas **perde os valores do contexto pai**, como trace IDs, spans de observabilidade, credenciais de autenticação propagadas, etc.

```go
// Com context.Background() — trace ID perdido
enrichCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

// Com context.WithoutCancel — trace ID preservado
enrichCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
```

Use `context.WithoutCancel` quando quiser o isolamento do cancelamento sem abrir mão da rastreabilidade.

## Exemplo completo: notificação opcional

Aqui está um exemplo mais concreto de um handler HTTP que envia uma notificação opcional após criar um recurso:

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

## Exemplo completo: geração de conteúdo com IA

Outro padrão comum é usar IA para gerar conteúdo com fallback para texto estático:

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

## Checklist: quando usar context.WithoutCancel

Use `context.WithoutCancel` quando **todas** estas condições forem verdadeiras:

*   A operação é **opcional**, existe um fallback se ela falhar.

*   O erro da operação é **intencionalmente swallowed** (ou apenas logado).

*   Após a operação opcional, existem **outras operações obrigatórias** que ainda usarão o contexto pai.

*   Você quer **preservar os valores** do contexto (trace, auth, etc.).


Se a operação for obrigatória (sem fallback), não use `WithoutCancel`, deixe o cancelamento propagar normalmente.

## Resumo

| Situação | Abordagem |
| --- | --- |
| Operação obrigatória | Passe `ctx` diretamente |
| Operação opcional, sem rastreabilidade necessária | `context.WithTimeout(context.Background(), d)` |
| Operação opcional, com rastreabilidade | `context.WithTimeout(context.WithoutCancel(ctx), d)` |
| Goroutine de background de longa duração | Crie um contexto raiz com `context.Background()` |

O bug descrito aqui é fácil de introduzir e difícil de diagnosticar porque o erro aparece em um lugar diferente de onde o contexto foi cancelado. A regra geral é: **se você está swallowing um erro de contexto, verifique se o contexto que você está swallowing é o mesmo que será usado nas próximas chamadas**.

`context.WithoutCancel` é a ferramenta certa para separar o ciclo de vida de operações opcionais do ciclo de vida da requisição principal, sem perder a rastreabilidade.
