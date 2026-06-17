---
title: Construindo Agentes de IA de Verdade com o Copilot SDK em Go
description: Se você acompanha o ecossistema do GitHub Copilot, provavelmente já ouviu falar dos arquivos *.agent.md. Eles são legais para coisas simples, basicamente um prompt turbinado que roda dentro do Copilot
date: "2026-04-22T10:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - go
    - developer-experience
    - architecture
url: /construindo-agentes-de-ia-de-verdade-com-o-copilot-sdk-em-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Se você acompanha o ecossistema do GitHub Copilot, provavelmente já ouviu falar dos arquivos `*.agent.md`. Eles são legais para coisas simples, basicamente um prompt turbinado que roda dentro do Copilot. Mas quando você precisa de um agente **de verdade**, que chama APIs, consulta bancos de dados, aplica políticas de permissão, injeta contexto via RAG e roda em produção como um microserviço... Markdown não dá conta.

É aí que entra o [GitHub Copilot SDK](https://github.com/github/copilot-sdk).

Neste post, vou mostrar como construir um agente de resposta a incidentes, do zero até um container pronto para deploy, usando o SDK em Go. A ideia é que, ao final, você tenha uma visão completa de tudo que o SDK oferece e **por que** ele existe.

## O que o Copilot SDK faz que um `agent.md` não faz?

Antes de mergulhar no código, vale entender o gap:

| Capacidade | `*.agent.md` | Copilot SDK |
| --- | --- | --- |
| Ferramentas customizadas em código nativo (sem o overhead de um MCP externo) | ⚠️ via MCP server separado | ✅ |
| Hooks (interceptar prompts, tool calls, erros) | ⚠️ `PostToolUse` via shell (Preview no VS Code) | ✅ |
| Controle de permissões (aprovar/negar por tipo) | ❌ | ✅ |
| Streaming com delta events | ❌ | ✅ |
| UI de elicitação (formulários, seleções) | ❌ | ✅ |
| Sessões infinitas com compactação automática | ❌ | ✅ |
| Controle granular do system prompt (por seção) | ❌ | ✅ |
| Orquestração programática multi-sessão | ⚠️ subagents + handoffs declarativos no VS Code | ✅ |
| BYOK (Bring Your Own Key) | ❌ | ✅ |
| Telemetria (OpenTelemetry nativo) | ❌ | ✅ |
| Embutir em um backend/CLI/worker | ❌ | ✅ |
| Slash commands customizados | ❌ | ✅ |
| Override de ferramentas built-in | ❌ | ✅ |

O `agent.md` é ótimo para instruções estáticas. O SDK é para quando você precisa de **lógica de verdade**.

## Arquitetura: como o SDK funciona

O Copilot SDK segue uma arquitetura de dois processos. Sua aplicação fala com o SDK, que se comunica com o Copilot CLI via JSON-RPC:

```plaintext
Sua Aplicação (API/Worker/CLI)
       ↓
  SDK Client
       ↓ JSON-RPC (stdio ou TCP)
  Copilot CLI (modo headless)
       ↓
  ☁️ GitHub Copilot / Provedor de modelo
```

O Go SDK tem um diferencial importante em relação aos outros SDKs: ele consegue **embutir o binário do CLI** diretamente no seu binário Go usando `//go:embed`. Isso significa que seu artefato final é um **único binário estático** sem dependências externas, perfeito para containers distroless.

## O que vamos construir

Um **Incident Commander Agent**, um agente que engenheiros de plantão podem acionar durante um incidente de produção. Ele:

*   Consulta métricas no Prometheus automaticamente

*   Busca runbooks de uma base de conhecimento

*   Injeta contexto de incidentes passados via RAG

*   Escala serviços no Kubernetes e faz rollback de deploys

*   Exige confirmação antes de ações destrutivas

*   Registra tudo em um audit log

*   Exporta traces via OpenTelemetry


Tudo isso empacotado em um único binário Go dentro de um container de ~60MB.

## Configurando o projeto

```shell
mkdir incident-commander && cd incident-commander
go mod init github.com/seu-usuario/incident-commander

# Adiciona o SDK
go get github.com/github/copilot-sdk/go

# Adiciona o bundler como ferramenta (uma vez só)
go get -tool github.com/github/copilot-sdk/go/cmd/bundler
```

## Estrutura do projeto

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

## Ferramentas customizadas

Aqui é onde o SDK brilha. Cada ferramenta é uma função Go tipada que o modelo pode chamar quando precisar:

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

Repare no `SkipPermission = true` nas ferramentas de leitura. Ferramentas que apenas consultam dados não precisam pedir permissão. Já `scale_service` e `rollback_deploy` vão passar pelo handler de permissões, que veremos a seguir.

O `DefineTool` usa generics e o pacote `jsonschema-go` para gerar o JSON Schema automaticamente a partir das structs Go. As tags `jsonschema:"..."` viram as descrições dos parâmetros para o modelo.

## Permissões: controle fino sobre o que o agente pode fazer

O handler de permissões é **obrigatório** no SDK. Você precisa decidir explicitamente o que aprovar ou negar. Isso é um design intencional: agentes em produção precisam de guardrails.

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

Isso é algo impossível com `agent.md`. Lá, o agente roda com as permissões padrão do Copilot. Aqui, **você** define a política.

## Hooks: RAG, auditoria e tratamento de erros

Os hooks são interceptadores que rodam em momentos específicos do ciclo de vida da sessão. Vamos usar três:

1.  `OnUserPromptSubmitted`: injeta contexto de incidentes passados (RAG) antes do modelo processar

2.  `OnPostToolUse`: loga cada execução de ferramenta

3.  `OnErrorOccurred`: define estratégia de retry/skip/abort


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

O hook de RAG é particularmente poderoso. Toda vez que o engenheiro envia uma mensagem, o hook intercepta o prompt **antes** de chegar ao modelo, consulta um banco vetorial de post-mortems passados e injeta os resultados mais relevantes como contexto adicional. O modelo recebe a mensagem do engenheiro **junto** com incidentes similares, sem que o engenheiro precise buscar manualmente. Isso é completamente transparente para quem está usando.

## Montando a sessão do agente

Agora juntamos tudo: ferramentas, hooks, permissões e configuração do system prompt:

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

Repare no `SystemMessage` com `Mode: "customize"`. Em vez de substituir o prompt inteiro ou apenas concatenar texto no final, o SDK permite **controlar seção por seção**: substituir a identidade, remover regras de código (irrelevantes para esse agente), e adicionar guidelines específicas. As outras seções (safety, tool instructions, etc.) são preservadas automaticamente.

O `InfiniteSessions` com `BackgroundCompactionThreshold: 0.80` faz com que, quando o contexto atingir 80% da janela, o SDK automaticamente compacte o histórico em background, sem que o engenheiro perceba. Isso é essencial para incidentes longos com centenas de mensagens.

## Triggers: quando e como o agente é acionado?

O agente é um servidor HTTP que fica sempre rodando. A questão é: **quem chama ele, e quando?** Existem vários padrões, e na prática você combina mais de um.

### Webhook do PagerDuty (trigger principal)

Quando um alerta dispara, o PagerDuty envia um webhook. O agente recebe, cria uma sessão, roda o diagnóstico inicial e posta no Slack:

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

### Slack Bot (conversa interativa)

Depois do diagnóstico inicial, o engenheiro continua a conversa pelo Slack. Cada mensagem é um `SendAndWait` na mesma sessão:

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

### Webhook do Alertmanager (direto dos alertas)

Você pode cortar o PagerDuty e reagir diretamente aos alertas do Prometheus:

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

### Cron (health checks proativos)

O agente não precisa ser apenas reativo. Ele pode rodar periodicamente e **encontrar problemas antes que virem incidentes**:

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

## O entry point: juntando tudo

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

## O CLI embutido: como funciona

O Go SDK tem um **bundler** que automatiza todo o processo de embutir o Copilot CLI no seu binário.

O que acontece quando você roda `go tool bundler`:

1.  Lê o `go.mod` para detectar a versão do SDK

2.  Busca a versão correspondente do CLI no npm registry

3.  Baixa o binário específico para a plataforma alvo (ex: `linux/amd64`)

4.  Comprime com zstd

5.  Gera um arquivo Go com a diretiva `//go:embed`


O arquivo gerado é mais ou menos assim:

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

No runtime, quando `NewClient` detecta que não tem `CLIPath` nem `COPILOT_CLI_PATH`, ele usa o blob embutido: descomprime para um diretório de cache e verifica o SHA-256.

O build completo fica assim:

```bash
#!/bin/bash
set -euo pipefail

# 1. Baixa + embute o CLI para a plataforma alvo
go tool bundler --platform linux/amd64

# 2. Compila o binário final
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o incident-commander .
```

## Dockerfile: multi-stage com distroless

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

Por que `distroless/static`? Como o binário Go é totalmente estático (`CGO_ENABLED=0`) e o Copilot CLI embutido também é estático, **não existem dependências de SO**. Sem apt, sem bash, sem glibc. A imagem final fica em torno de 60-90MB (seu binário + CLI comprimido). Isso também significa menos CVEs para se preocupar.

## Docker Compose para desenvolvimento local

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

## Deploy no Kubernetes

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

Você deploya esse agente **exatamente como qualquer outro microserviço Go**. O único detalhe extra é o volume persistente para o estado das sessões.

## CI/CD com GitHub Actions

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

O cache do `zcopilot_*` evita re-download do CLI a cada build. Ele só muda quando o SDK é atualizado (refletido no `go.sum`).

## Considerações para produção

Algumas coisas importantes para manter isso rodando de verdade:

| Preocupação | Recomendação |
| --- | --- |
| **Storage** | Monte `/home/nonroot/.copilot/session-state/` em volume persistente |
| **Secrets** | Use K8s Secrets ou Vault para o `COPILOT_GITHUB_TOKEN` |
| **Health check** | `client.Ping()` como liveness probe, reinicie se não responder |
| **Cleanup de sessões** | Cron para deletar sessões mais velhas que 24h (+ auto-cleanup de 30min idle) |
| **Locking** | Redis `SETNX` se múltiplos pods acessam a mesma sessão |
| **Observabilidade** | OpenTelemetry → OTLP collector → Grafana/Jaeger |
| **Graceful shutdown** | Drene sessões ativas antes de parar o CLI |
| **Rate limiting** | Aplique na sua camada de API, o SDK não limita |

## Conclusão

O Copilot SDK transforma o Copilot de um assistente de código em uma **runtime de agentes**. Você define o comportamento em código (não em Markdown), controla permissões, intercepta o fluxo com hooks, injeta contexto dinâmico, e deploya como qualquer microserviço.

O Go SDK em particular tem uma proposta muito elegante: o bundler + `//go:embed` gera um **único binário estático** com o CLI incluso. Sem sidecar, sem Docker-in-Docker, sem dependência externa. `go build` e pronto.

O agente que construímos aqui é um caso real: recebe webhooks de sistemas de monitoramento, diagnostica incidentes de forma autônoma, mantém conversas com engenheiros via Slack, e executa remediações com gates de permissão. Tudo observável via OpenTelemetry.

Isso não é um "Hello, World!" com IA. É um microserviço de produção que por acaso tem um LLM dentro.

* * *

*O código e os exemplos deste post estão baseados na* [*documentação do Copilot SDK*](https://github.com/github/copilot-sdk)*. O SDK está em public preview, confira o repositório para a versão mais recente.*
