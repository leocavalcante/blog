---
title: Building Real AI Agents with the Copilot SDK in Go
description: If you follow the GitHub Copilot ecosystem, you have probably heard of *.agent.md files. They are great for simple things, basically a boosted prompt that runs inside Copilot
date: "2026-04-22T08:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - go
    - developer-experience
    - architecture
url: /en/construindo-agentes-de-ia-de-verdade-com-o-copilot-sdk-em-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

If you follow the GitHub Copilot ecosystem, you have probably heard of `*.agent.md` files. They are great for simple things, basically a boosted prompt that runs inside Copilot. But when you need a **real** agent that calls APIs, queries databases, applies permission policies, injects context through RAG, and runs in production as a microservice... Markdown is not enough.

That is where the [GitHub Copilot SDK](https://github.com/github/copilot-sdk) comes in.

In this post, I will show how to build an incident response agent, from scratch to a deploy-ready container, using the SDK in Go. The idea is that, by the end, you will have a complete view of everything the SDK offers and **why** it exists.

## What does the Copilot SDK do that an `agent.md` does not?

Before diving into the code, it is worth understanding the gap:

| Capability | `*.agent.md` | Copilot SDK |
| --- | --- | --- |
| Custom tools in native code (without the overhead of an external MCP) | ⚠️ via a separate MCP server | ✅ |
| Hooks (intercept prompts, tool calls, errors) | ⚠️ `PostToolUse` via shell (Preview in VS Code) | ✅ |
| Permission control (approve/deny by type) | ❌ | ✅ |
| Streaming with delta events | ❌ | ✅ |
| Elicitation UI (forms, selections) | ❌ | ✅ |
| Infinite sessions with automatic compaction | ❌ | ✅ |
| Granular system prompt control (by section) | ❌ | ✅ |
| Programmatic multi-session orchestration | ⚠️ subagents + declarative handoffs in VS Code | ✅ |
| BYOK (Bring Your Own Key) | ❌ | ✅ |
| Telemetry (native OpenTelemetry) | ❌ | ✅ |
| Embedding in a backend/CLI/worker | ❌ | ✅ |
| Custom slash commands | ❌ | ✅ |
| Built-in tool overrides | ❌ | ✅ |

The `agent.md` is great for static instructions. The SDK is for when you need **real logic**.

## Architecture: how the SDK works

The Copilot SDK follows a two-process architecture. Your application talks to the SDK, which communicates with the Copilot CLI over JSON-RPC:

```plaintext
Sua Aplicação (API/Worker/CLI)
       ↓
  SDK Client
       ↓ JSON-RPC (stdio ou TCP)
  Copilot CLI (modo headless)
       ↓
  ☁️ GitHub Copilot / Provedor de modelo
```

The Go SDK has an important advantage over the other SDKs: it can **embed the CLI binary** directly into your Go binary using `//go:embed`. This means your final artifact is a **single static binary** with no external dependencies, perfect for distroless containers.

## What we are going to build

An **Incident Commander Agent**, an agent that on-call engineers can trigger during a production incident. It:

*   Queries metrics in Prometheus automatically

*   Fetches runbooks from a knowledge base

*   Injects context from past incidents through RAG

*   Scales services in Kubernetes and rolls back deploys

*   Requires confirmation before destructive actions

*   Records everything in an audit log

*   Exports traces through OpenTelemetry


All of this packaged in a single Go binary inside a ~60MB container.

## Setting up the project

```shell
mkdir incident-commander && cd incident-commander
go mod init github.com/seu-usuario/incident-commander

# Adiciona o SDK
go get github.com/github/copilot-sdk/go

# Adiciona o bundler como ferramenta (uma vez só)
go get -tool github.com/github/copilot-sdk/go/cmd/bundler
```

## Project structure

```plaintext
incident-commander/
├── main.go                       # Entry point + HTTP server
├── agent.go                      # Sessão, permissões, hooks
├── tools.go                      # Ferramentas customizadas
├── webhooks.go                   # Webhooks (PagerDuty, AM)
├── slack.go                      # Integração com Slack
├── cron.go                       # Health checks proativos
├── go.mod
├── go.sum
├── Dockerfile
├── docker-compose.yml
├── zcopilot_*_linux_amd64.zst      # ← gerado pelo bundler
├── zcopilot_*_linux_amd64.license  # ← gerado pelo bundler
└── zcopilot_linux_amd64.go         # ← gerado pelo bundler
```

## Custom tools

This is where the SDK shines. Each tool is a typed Go function that the model can call when needed:

```go
package main

import (
	"fmt"
	copilot "github.com/github/copilot-sdk/go"
)

type QueryPrometheusParams struct {
	Query    string `json:"query" jsonschema:"PromQL query string"`
	Duration string `json:"duration,omitempty" jsonschema:"Time range (e.g. 5m, 1h). Default: 5m"`
}

type GetRunbookParams struct {
	Service string `json:"service" jsonschema:"Service name to look up runbook for"`
}

type ScaleServiceParams struct {
	Service  string `json:"service" jsonschema:"Kubernetes service/deployment name"`
	Replicas int    `json:"replicas" jsonschema:"Target replica count"`
}

type RollbackDeployParams struct {
	Service string `json:"service" jsonschema:"Service to rollback"`
	Version string `json:"version,omitempty" jsonschema:"Target version. If empty, rolls back to previous."`
}

func incidentTools() []copilot.Tool {
	queryPrometheus := copilot.DefineTool("query_prometheus",
		"Query Prometheus for metrics. Use for CPU, memory, error rates, latency percentiles, and Kafka consumer lag.",
		func(params QueryPrometheusParams, inv copilot.ToolInvocation) (any, error) {
			duration := params.Duration
			if duration == "" {
				duration = "5m"
			}
			result, err := prometheusQuery(params.Query, duration)
			if err != nil {
				return nil, fmt.Errorf("prometheus query failed: %w", err)
			}
			return result, nil
		})
	queryPrometheus.SkipPermission = true // read-only, auto-approve

	getRunbook := copilot.DefineTool("get_runbook",
		"Retrieve the incident runbook for a service from the knowledge base.",
		func(params GetRunbookParams, inv copilot.ToolInvocation) (any, error) {
			runbook, err := fetchRunbook(params.Service)
			if err != nil {
				return nil, err
			}
			return runbook, nil
		})
	getRunbook.SkipPermission = true

	scaleService := copilot.DefineTool("scale_service",
		"Scale a Kubernetes deployment. Requires engineer confirmation.",
		func(params ScaleServiceParams, inv copilot.ToolInvocation) (any, error) {
			if err := kubeScale(params.Service, params.Replicas); err != nil {
				return nil, err
			}
			return fmt.Sprintf("Scaled %s to %d replicas", params.Service, params.Replicas), nil
		})

	rollbackDeploy := copilot.DefineTool("rollback_deploy",
		"Rollback a service deployment via the CD pipeline. DESTRUCTIVE, requires confirmation.",
		func(params RollbackDeployParams, inv copilot.ToolInvocation) (any, error) {
			version, err := triggerRollback(params.Service, params.Version)
			if err != nil {
				return nil, err
			}
			return fmt.Sprintf("Rollback of %s to %s initiated", params.Service, version), nil
		})

	return []copilot.Tool{queryPrometheus, getRunbook, scaleService, rollbackDeploy}
}
```

Notice `SkipPermission = true` on the read tools. Tools that only query data do not need to ask for permission. Meanwhile, `scale_service` and `rollback_deploy` will go through the permission handler, which we will see next.

`DefineTool` uses generics and the `jsonschema-go` package to generate the JSON Schema automatically from the Go structs. The `jsonschema:"..."` tags become the parameter descriptions for the model.

## Permissions: fine-grained control over what the agent can do

The permission handler is **mandatory** in the SDK. You need to explicitly decide what to approve or deny. This is intentional design: production agents need guardrails.

```go
package main

import (
	"log"
	copilot "github.com/github/copilot-sdk/go"
)

func incidentPermissionHandler() copilot.PermissionHandlerFunc {
	return func(req copilot.PermissionRequest, inv copilot.PermissionInvocation) (copilot.PermissionRequestResult, error) {
		switch req.Kind {
		case "shell":
			// Nunca permitir execução de comandos shell
			log.Printf("[PERMISSION DENIED] Shell command blocked: %v", req.FullCommandText)
			return copilot.PermissionRequestResult{
				Kind: copilot.PermissionRequestResultKindDeniedByRules,
			}, nil

		case "custom_tool":
			toolName := ""
			if req.ToolName != nil {
				toolName = *req.ToolName
			}

			switch toolName {
			case "query_prometheus", "get_runbook":
				return copilot.PermissionRequestResult{
					Kind: copilot.PermissionRequestResultKindApproved,
				}, nil
			case "scale_service", "rollback_deploy":
				// Aprovar, mas logar para audit trail
				log.Printf("[AUDIT] Destructive tool approved: %s (call: %v)", toolName, req.ToolCallID)
				return copilot.PermissionRequestResult{
					Kind: copilot.PermissionRequestResultKindApproved,
				}, nil
			}
		}

		// Default: approve
		return copilot.PermissionRequestResult{
			Kind: copilot.PermissionRequestResultKindApproved,
		}, nil
	}
}
```

This is impossible with `agent.md`. There, the agent runs with Copilot's default permissions. Here, **you** define the policy.

## Hooks: RAG, auditing, and error handling

Hooks are interceptors that run at specific points in the session lifecycle. We will use three:

1.  `OnUserPromptSubmitted`: injects context from past incidents (RAG) before the model processes it

2.  `OnPostToolUse`: logs every tool execution

3.  `OnErrorOccurred`: defines the retry/skip/abort strategy


```go
package main

import (
	"fmt"
	"log"
	copilot "github.com/github/copilot-sdk/go"
)

func incidentHooks() *copilot.SessionHooks {
	return &copilot.SessionHooks{
		// RAG: enriquece cada prompt com incidentes passados similares
		OnUserPromptSubmitted: func(input copilot.UserPromptSubmittedHookInput, inv copilot.HookInvocation) (*copilot.UserPromptSubmittedHookOutput, error) {
			context, err := ragSearch(input.Prompt)
			if err != nil {
				log.Printf("[RAG] Search failed (non-fatal): %v", err)
				return &copilot.UserPromptSubmittedHookOutput{
					ModifiedPrompt: input.Prompt,
				}, nil
			}

			enriched := fmt.Sprintf(
				"%s\n\n<past_incidents>\n%s\n</past_incidents>",
				input.Prompt, context,
			)
			return &copilot.UserPromptSubmittedHookOutput{
				ModifiedPrompt: enriched,
			}, nil
		},

		// Audit: loga cada execução de ferramenta
		OnPostToolUse: func(input copilot.PostToolUseHookInput, inv copilot.HookInvocation) (*copilot.PostToolUseHookOutput, error) {
			log.Printf("[TOOL] %s completed (session: %s)", input.ToolName, inv.SessionID)
			return &copilot.PostToolUseHookOutput{}, nil
		},

		// Erros: retry automático em falhas transientes
		OnErrorOccurred: func(input copilot.ErrorOccurredHookInput, inv copilot.HookInvocation) (*copilot.ErrorOccurredHookOutput, error) {
			log.Printf("[ERROR] %s in context %s", input.Error, input.ErrorContext)
			return &copilot.ErrorOccurredHookOutput{
				ErrorHandling: "retry",
			}, nil
		},
	}
}

func ragSearch(query string) (string, error) {
	// Na prática: consulte seu vector DB (pgvector, Pinecone, Weaviate, etc.)
	return "Incidente similar (INC-2024-0312): spike de latência p99 causado por exaustão do connection pool. Resolvido escalando para 8 réplicas e reiniciando pods.", nil
}
```

The RAG hook is particularly powerful. Every time the engineer sends a message, the hook intercepts the prompt **before** it reaches the model, queries a vector database of past postmortems, and injects the most relevant results as additional context. The model receives the engineer's message **together** with similar incidents, without the engineer having to search manually. This is completely transparent to the person using it.

## Assembling the agent session

Now we put everything together: tools, hooks, permissions, and system prompt configuration:

```go
package main

import (
	"context"
	copilot "github.com/github/copilot-sdk/go"
)

func createIncidentSession(ctx context.Context, client *copilot.Client, sessionID, prompt string) (*copilot.Session, error) {
	return client.CreateSession(ctx, &copilot.SessionConfig{
		SessionID: sessionID,
		Model:     "gpt-4.1",
		Streaming: true,
		Tools:     incidentTools(),
		Hooks:     incidentHooks(),
		SystemMessage: &copilot.SystemMessageConfig{
			Mode: "customize",
			Sections: map[string]copilot.SectionOverride{
				copilot.SectionIdentity: {
					Action:  "replace",
					Content: "You are an Incident Commander assistant. You help on-call engineers diagnose and resolve production incidents.",
				},
				copilot.SectionCodeChangeRules: {Action: "remove"},
				copilot.SectionGuidelines: {
					Action: "append",
					Content: `
* Always check metrics before suggesting a remediation.
* Never execute a rollback without explicit engineer confirmation.
* Log every destructive action.`,
				},
			},
			Content: "Focus on incident triage, diagnosis, and remediation for a microservices platform.",
		},
		OnPermissionRequest: incidentPermissionHandler(),
		InfiniteSessions: &copilot.InfiniteSessionConfig{
			Enabled:                       copilot.Bool(true),
			BackgroundCompactionThreshold: copilot.Float64(0.80),
		},
	})
}
```

Notice the `SystemMessage` with `Mode: "customize"`. Instead of replacing the entire prompt or only concatenating text at the end, the SDK lets you **control it section by section**: replace the identity, remove code rules (irrelevant for this agent), and add specific guidelines. The other sections (safety, tool instructions, etc.) are preserved automatically.

`InfiniteSessions` with `BackgroundCompactionThreshold: 0.80` makes the SDK automatically compact the history in the background when the context reaches 80% of the window, without the engineer noticing. This is essential for long incidents with hundreds of messages.

## Triggers: when and how is the agent triggered?

The agent is an HTTP server that keeps running. The question is: **who calls it, and when?** There are several patterns, and in practice you combine more than one.

### PagerDuty webhook (main trigger)

When an alert fires, PagerDuty sends a webhook. The agent receives it, creates a session, runs the initial diagnosis, and posts to Slack:

```go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	copilot "github.com/github/copilot-sdk/go"
)

type PagerDutyWebhook struct {
	Event struct {
		EventType string `json:"event_type"`
		Data      struct {
			ID      string `json:"id"`
			Title   string `json:"title"`
			Service struct {
				Name string `json:"name"`
			} `json:"service"`
			Urgency   string `json:"urgency"`
			Assignees []struct {
				Summary string `json:"summary"`
			} `json:"assignees"`
		} `json:"data"`
	} `json:"event"`
}

func handlePagerDutyWebhook(ctx context.Context, client *copilot.Client, w http.ResponseWriter, r *http.Request) {
	var webhook PagerDutyWebhook
	if err := json.NewDecoder(r.Body).Decode(&webhook); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if webhook.Event.EventType != "incident.triggered" {
		w.WriteHeader(http.StatusOK)
		return
	}

	data := webhook.Event.Data
	sessionID := fmt.Sprintf("incident-%s", data.ID)

	prompt := fmt.Sprintf(
		`A new incident has been triggered:
- **Incident**: %s
- **Service**: %s
- **Urgency**: %s
- **ID**: %s

Please:
1. Query Prometheus for the current health of service "%s" (error rate, p99 latency, CPU, memory)
2. Fetch the runbook for this service
3. Provide an initial triage summary with likely root cause and recommended actions`,
		data.Title, data.Service.Name, data.Urgency, data.ID, data.Service.Name,
	)

	session, err := createIncidentSession(ctx, client, sessionID, prompt)
	if err != nil {
		log.Printf("[WEBHOOK] Failed to create session: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response, err := session.SendAndWait(ctx, copilot.MessageOptions{Prompt: prompt})
	if err != nil {
		log.Printf("[WEBHOOK] Agent failed: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if d, ok := response.Data.(*copilot.AssistantMessageData); ok {
		postToSlack(data.Service.Name, data.ID, sessionID, d.Content)
	}

	w.WriteHeader(http.StatusAccepted)
}
```

### Slack Bot (interactive conversation)

After the initial diagnosis, the engineer continues the conversation through Slack. Each message is a `SendAndWait` in the same session:

```go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"

	copilot "github.com/github/copilot-sdk/go"
)

var threadToSession sync.Map

type SlackEvent struct {
	Type      string `json:"type"`
	Challenge string `json:"challenge"`
	Event     struct {
		Type     string `json:"type"`
		Text     string `json:"text"`
		Channel  string `json:"channel"`
		ThreadTS string `json:"thread_ts"`
		TS       string `json:"ts"`
		User     string `json:"user"`
	} `json:"event"`
}

func handleSlackEvent(ctx context.Context, client *copilot.Client, w http.ResponseWriter, r *http.Request) {
	var event SlackEvent
	if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if event.Type == "url_verification" {
		json.NewEncoder(w).Encode(map[string]string{"challenge": event.Challenge})
		return
	}

	threadTS := event.Event.ThreadTS
	if threadTS == "" {
		threadTS = event.Event.TS
	}

	message := stripBotMention(event.Event.Text)
	if message == "" {
		w.WriteHeader(http.StatusOK)
		return
	}

	sessionIDVal, ok := threadToSession.Load(threadTS)
	if !ok {
		w.WriteHeader(http.StatusOK)
		return
	}
	sessionID := sessionIDVal.(string)

	go func() {
		session, err := client.ResumeSession(ctx, sessionID, &copilot.ResumeSessionConfig{
			OnPermissionRequest: incidentPermissionHandler(),
		})
		if err != nil {
			log.Printf("[SLACK] Failed to resume session %s: %v", sessionID, err)
			return
		}
		defer session.Disconnect()

		response, err := session.SendAndWait(ctx, copilot.MessageOptions{
			Prompt: fmt.Sprintf("[Engineer %s]: %s", event.Event.User, message),
		})
		if err != nil {
			return
		}

		if d, ok := response.Data.(*copilot.AssistantMessageData); ok {
			postToSlackThread(event.Event.Channel, threadTS, d.Content)
		}
	}()

	w.WriteHeader(http.StatusOK)
}

func stripBotMention(text string) string {
	if idx := strings.Index(text, "> "); idx != -1 {
		return strings.TrimSpace(text[idx+2:])
	}
	return strings.TrimSpace(text)
}
```

### Alertmanager webhook (directly from alerts)

You can skip PagerDuty and react directly to Prometheus alerts:

```yaml
# alertmanager.yml
route:
  receiver: incident-commander
  group_by: ['alertname', 'service']
  group_wait: 30s

receivers:
  - name: incident-commander
    webhook_configs:
      - url: 'http://incident-commander:8080/api/webhook/alertmanager'
        send_resolved: true
```

### Cron (proactive health checks)

The agent does not have to be only reactive. It can run periodically and **find problems before they become incidents**:

```go
package main

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

	copilot "github.com/github/copilot-sdk/go"
)

func StartHealthCheckCron(ctx context.Context, client *copilot.Client, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			runProactiveCheck(ctx, client)
		}
	}
}

func runProactiveCheck(ctx context.Context, client *copilot.Client) {
	sessionID := fmt.Sprintf("healthcheck-%d", time.Now().Unix())

	session, err := createIncidentSession(ctx, client, sessionID,
		`Run a proactive health check across critical services:
1. Check error rates for the main services
2. Check p99 latency for each
3. Check Kafka consumer lag for payment processing topics
4. Flag anything anomalous with severity and recommended action`)
	if err != nil {
		log.Printf("[CRON] Failed: %v", err)
		return
	}

	response, err := session.SendAndWait(ctx, copilot.MessageOptions{
		Prompt: "Run proactive health check now.",
	})
	if err != nil {
		log.Printf("[CRON] Agent failed: %v", err)
		return
	}

	if d, ok := response.Data.(*copilot.AssistantMessageData); ok {
		if strings.Contains(strings.ToLower(d.Content), "anomal") ||
			strings.Contains(strings.ToLower(d.Content), "elevated") ||
			strings.Contains(strings.ToLower(d.Content), "degraded") {
			postToSlack("platform", "proactive-check", sessionID, d.Content)
		}
	}

	client.DeleteSession(ctx, sessionID)
}
```

## The entry point: putting it all together

```go
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	copilot "github.com/github/copilot-sdk/go"
)

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	// Sem CLIPath: o CLI embutido é usado automaticamente
	client := copilot.NewClient(&copilot.ClientOptions{
		LogLevel: "error",
		Telemetry: &copilot.TelemetryConfig{
			OTLPEndpoint: os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
			SourceName:   "incident-commander",
		},
	})

	if err := client.Start(ctx); err != nil {
		log.Fatalf("Failed to start Copilot client: %v", err)
	}
	defer client.Stop()

	log.Println("Copilot client started with embedded CLI")

	mux := http.NewServeMux()

	// Webhooks
	mux.HandleFunc("POST /api/webhook/pagerduty", func(w http.ResponseWriter, r *http.Request) {
		handlePagerDutyWebhook(ctx, client, w, r)
	})

	// Slack
	mux.HandleFunc("POST /api/slack/events", func(w http.ResponseWriter, r *http.Request) {
		handleSlackEvent(ctx, client, w, r)
	})

	// API direta
	mux.HandleFunc("POST /api/incident", func(w http.ResponseWriter, r *http.Request) {
		handleIncident(ctx, client, w, r)
	})
	mux.HandleFunc("POST /api/incident/{sessionID}/message", func(w http.ResponseWriter, r *http.Request) {
		handleMessage(ctx, client, w, r)
	})

	// Health check
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		if _, err := client.Ping(ctx, "health"); err != nil {
			http.Error(w, "unhealthy", 503)
			return
		}
		w.WriteHeader(200)
	})

	// Background: health checks proativos a cada 15 minutos
	go StartHealthCheckCron(ctx, client, 15*time.Minute)

	srv := &http.Server{Addr: ":8080", Handler: mux}
	go func() {
		<-ctx.Done()
		srv.Shutdown(context.Background())
	}()

	log.Println("Incident Commander listening on :8080")
	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
```

## The embedded CLI: how it works

The Go SDK has a **bundler** that automates the whole process of embedding the Copilot CLI into your binary.

What happens when you run `go tool bundler`:

1.  Reads `go.mod` to detect the SDK version

2.  Looks up the corresponding CLI version in the npm registry

3.  Downloads the platform-specific binary for the target platform (for example, `linux/amd64`)

4.  Compresses it with zstd

5.  Generates a Go file with the `//go:embed` directive


The generated file looks roughly like this:

```go
// Code generated by copilot-sdk bundler; DO NOT EDIT.
package main

import (
    _ "embed"
    "github.com/github/copilot-sdk/go/embeddedcli"
)

//go:embed zcopilot_0.25.0_linux_amd64.zst
var localEmbeddedCopilotCLI []byte

func init() {
    embeddedcli.Setup(embeddedcli.Config{
        Cli:     cliReader(), // descomprime o zst
        Version: "0.25.0",
        CliHash: mustDecodeBase64("sha256-hash..."),
    })
}
```

At runtime, when `NewClient` detects there is no `CLIPath` and no `COPILOT_CLI_PATH`, it uses the embedded blob: decompresses it into a cache directory and verifies the SHA-256.

The complete build looks like this:

```bash
#!/bin/bash
set -euo pipefail

# 1. Baixa + embute o CLI para a plataforma alvo
go tool bundler --platform linux/amd64

# 2. Compila o binário final
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o incident-commander .
```

## Dockerfile: multi-stage with distroless

```dockerfile
# Stage 1: Build
FROM golang:1.24-bookworm AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Baixa e embute o CLI
RUN go tool bundler --platform linux/amd64

# Compila binário estático
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /incident-commander .

# Stage 2: Runtime (distroless para superfície de ataque mínima)
FROM gcr.io/distroless/static-debian12:nonroot

ENV HOME=/home/nonroot

COPY --from=builder /incident-commander /incident-commander

# Sessões persistem aqui: monte um volume em produção
VOLUME /home/nonroot/.copilot/session-state

EXPOSE 8080

ENTRYPOINT ["/incident-commander"]
```

Why `distroless/static`? Since the Go binary is fully static (`CGO_ENABLED=0`) and the embedded Copilot CLI is also static, **there are no OS dependencies**. No apt, no bash, no glibc. The final image is around 60-90MB (your binary + compressed CLI). This also means fewer CVEs to worry about.

## Docker Compose for local development

```yaml
version: "3.8"

services:
  incident-commander:
    build: .
    ports:
      - "8080:8080"
    environment:
      - COPILOT_GITHUB_TOKEN=${COPILOT_GITHUB_TOKEN}
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
    volumes:
      - session-data:/home/nonroot/.copilot/session-state
    depends_on:
      - otel-collector
    restart: unless-stopped

  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    ports:
      - "4318:4318"
    volumes:
      - ./otel-config.yaml:/etc/otelcol-contrib/config.yaml

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"

volumes:
  session-data:
```

## Deploying on Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: incident-commander
spec:
  replicas: 2
  selector:
    matchLabels:
      app: incident-commander
  template:
    metadata:
      labels:
        app: incident-commander
    spec:
      containers:
        - name: agent
          image: ghcr.io/seu-usuario/incident-commander:latest
          ports:
            - containerPort: 8080
          env:
            - name: COPILOT_GITHUB_TOKEN
              valueFrom:
                secretKeyRef:
                  name: copilot-secrets
                  key: github-token
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: "http://otel-collector.observability:4318"
          volumeMounts:
            - name: session-state
              mountPath: /home/nonroot/.copilot/session-state
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 30
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "1Gi"
              cpu: "500m"
      volumes:
        - name: session-state
          persistentVolumeClaim:
            claimName: incident-commander-sessions
```

You deploy this agent **exactly like any other Go microservice**. The only extra detail is the persistent volume for session state.

## CI/CD with GitHub Actions

```yaml
name: Build & Push

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.24"

      - uses: actions/cache@v4
        with:
          path: zcopilot_*
          key: copilot-cli-${{ hashFiles('go.sum') }}-linux-amd64

      - name: Bundle CLI
        run: go tool bundler --platform linux/amd64

      - name: Test
        run: go test ./...

      - name: Build & Push Container
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker build -t ghcr.io/seu-usuario/incident-commander:${{ github.sha }} .
          docker push ghcr.io/seu-usuario/incident-commander:${{ github.sha }}
```

The `zcopilot_*` cache avoids re-downloading the CLI on every build. It only changes when the SDK is updated (reflected in `go.sum`).

## Production considerations

Some important things for keeping this running for real:

| Concern | Recommendation |
| --- | --- |
| **Storage** | Mount `/home/nonroot/.copilot/session-state/` on a persistent volume |
| **Secrets** | Use K8s Secrets or Vault for `COPILOT_GITHUB_TOKEN` |
| **Health check** | `client.Ping()` as a liveness probe, restart if it does not respond |
| **Session cleanup** | Cron to delete sessions older than 24h (+ 30min idle auto-cleanup) |
| **Locking** | Redis `SETNX` if multiple pods access the same session |
| **Observability** | OpenTelemetry → OTLP collector → Grafana/Jaeger |
| **Graceful shutdown** | Drain active sessions before stopping the CLI |
| **Rate limiting** | Apply it in your API layer; the SDK does not limit |

## Conclusion

The Copilot SDK turns Copilot from a code assistant into an **agent runtime**. You define behavior in code (not Markdown), control permissions, intercept the flow with hooks, inject dynamic context, and deploy it like any microservice.

The Go SDK in particular has a very elegant proposition: the bundler + `//go:embed` generates a **single static binary** with the CLI included. No sidecar, no Docker-in-Docker, no external dependency. `go build`, and you are done.

The agent we built here is a real use case: it receives webhooks from monitoring systems, diagnoses incidents autonomously, keeps conversations with engineers going through Slack, and executes remediations with permission gates. Everything is observable through OpenTelemetry.

This is not an AI "Hello, World!". It is a production microservice that happens to have an LLM inside.

* * *

*The code and examples in this post are based on the* [*Copilot SDK documentation*](https://github.com/github/copilot-sdk)*. The SDK is in public preview; check the repository for the latest version.*
