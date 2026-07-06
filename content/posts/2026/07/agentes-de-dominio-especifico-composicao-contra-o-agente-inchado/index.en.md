---
title: "Domain-specific agents: composition against the bloated agent"
description: "The generic agent looks simple until it becomes a giant context window with too many tools, too many permissions, and too much cost. Domain-specific agents trade that accumulation for composition, clear boundaries, and cheaper execution."
date: "2026-07-06T08:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - architecture
    - software-engineering
url: /en/agentes-de-dominio-especifico-composicao-contra-o-agente-inchado/
cover: cover.jpg
cover_alt: "Workflow diagram, product brief, and user goals arranged on a table."
cover_credit_name: "Kelly Sikkema"
cover_credit_url: "https://unsplash.com/photos/workflow-diagram-product-brief-and-user-goals-are-shown-wdnpaTNwOEQ"
---

There is a comfortable way to build an AI agent: take a good model, write a large system prompt, connect half a dozen tools, add a few MCP servers, drop in Markdown skills, inject conversation history, and call it a platform.

At first, it works.

It works the same way a huge base class works at first. It handles the happy path, looks impressive in the demo, and feels efficient because everything is in one place. Then the bill arrives: bloated context, open permissions, unpredictable cost, behavior that is hard to debug, and an agent that has to reread the whole world to execute a small task.

That is the problem **domain-specific agents** try to solve.

They start from an old software engineering idea: composition beats inheritance when the system grows. Instead of creating a universal agent that inherits tools, instructions, and responsibilities from every domain, you create smaller agents with clear boundaries and compose them through a coordinator.

This is not architectural aesthetics. It is a way to reduce context, cost, and error surface.

## The bloated agent is the new God class

Every team building agents eventually hits the same temptation: add just one more tool.

Just one more Gmail integration. Just one more CRM query. Just one more skill for writing reports. Just one more MCP server. Just one more prompt rule. Just one more persistent memory. Just one more piece of history because it might be useful.

The agent keeps accumulating responsibility until it becomes a probabilistic God class.

The problem is not that those capabilities are useless. Many are necessary. The problem is that they live in the same execution space. The task "get Maria's latest email" travels alongside GitHub tools, compliance instructions, planning history, product docs, writing rules, shell commands, and whatever else has been placed in context.

That creates three costs.

The first is financial. Irrelevant tokens are still paid tokens.

The second is cognitive. The more the model sees, the more plausible paths it can invent.

The third is operational. When something goes wrong, it becomes hard to know whether the error came from the tool, the prompt, memory, model choice, history, or the interaction between all of them.

## A skill is not an agent

Skills are useful. Tools are useful. MCP is useful. The mistake is thinking any of them replaces a complete operational unit.

A skill is usually instruction. It teaches the agent how to do something. A tool executes an operation. An MCP server distributes tools and resources. All of that still usually lands inside the same agent, with the same history, the same identity, the same budget, and the same context window.

A domain-specific agent is different.

It has its own objective, prompt, tools, permissions, limits, evals, and telemetry. It is not a documentation file inside a larger agent. It is an executor with a contract.

A Gmail agent should not know how to scale Kubernetes. A billing agent should not be able to edit a repository. A PR review agent should not apply customer credit. That separation feels obvious in traditional systems, but it often disappears once we put a model in the center.

The model should not be an excuse to throw away architecture boundaries.

## Composition changes the reasoning unit

The practical difference shows up in the flow.

In the monolithic design, the user asks:

> Find Maria's latest email and create a task in Notion.

The main agent receives the request, rereads the history, sees every available tool, decides to use Gmail, then Notion, maybe checks something else, maybe loads instructions that do not matter, and continues.

In the composed design, the coordinator splits the work:

1. calls an email agent with a narrow task;
2. receives a structured response;
3. calls a Notion agent with another narrow task;
4. returns the result to the user.

The important detail is that the email agent does not need to receive the whole world. It receives the specific request, its domain prompt, and its tools. The Notion agent does the same. Context stops being a global dumping ground and becomes local input.

That changes the economics of the system.

The coordinator can keep using a stronger model to interpret intent, split work, and decide when to stop. Domain agents can use smaller models, smaller prompts, and narrower tools. In many cases, they do not need to be brilliant. They need to be consistent inside a well-designed task.

This is the part many agent discussions miss: not all intelligence needs to live in the same place.

## Token savings are a consequence, not the goal

Justin Schroeder from StandardAgents argues that domain-specific agents can bring large token-efficiency gains because each agent works with a much smaller context. The idea is intuitive: if a task only needs Gmail, it does not make sense to pay for the model to process GitHub, Sheets, Slack, shell, long history, and rules that do not participate in that execution.

But I would not treat token savings as the only argument.

The main gain is reducing mixing.

When context is smaller, behavior tends to become more legible. When the tool is narrower, the failure is more contained. When permission is local, the maximum accident gets smaller. When the agent has its own evals, you measure the domain instead of measuring a confusing average across unrelated tasks.

Tokens are the easy metric to see. Coupling is the deeper problem.

## Smaller models become more plausible

There is an implicit belief in a lot of agent architecture: if the system matters, use the most capable model for everything.

That is comfortable, but expensive.

A large model can compensate for a lot of mess. It understands poor instructions, navigates long context, picks tools through noise, and recovers from ambiguity better than smaller models. But that capability becomes an architectural crutch. You pay for general intelligence to solve a problem that might be better handled with a better boundary.

Domain-specific agents allow another strategy: use smaller models for smaller tasks.

An agent that only classifies support tickets into a stable taxonomy does not need the same model that coordinates a cross-repository migration. An agent that only turns an internal event into a spreadsheet row does not need the same reasoning as an incident investigation agent. An agent that validates whether a response follows policy can be small, cheap, and repeatable.

The point is not to use small models as ideology. It is to stop using large models as a substitute for system design.

## Security appears as a useful side effect

Domain-specific agents also improve security, but not because the prompt becomes more polite.

They improve security because the capability boundary gets smaller.

A billing agent can have permission to query invoices and propose adjustments. That does not imply permission to delete customers, change feature flags, read source code, or talk to production. A deployment agent can have permission to operate one service, in one region, with dry-run and approval. That does not imply broad access to the whole cloud account.

This limitation has to live in the harness, credentials, APIs, and orchestrator. The prompt can explain policy, but it cannot be the policy.

Composition helps because each agent carries a smaller identity. If everything flows through one super-agent with a huge credential, you are back to the old excessive-permission problem. If each domain has its own identity, tools, and limits, error is still possible, but the blast radius gets smaller.

That is reliability engineering as much as security.

## The coordinator cannot become another God agent

There is an obvious trap: take everything out of the main agent and put everything into the coordinator.

If the coordinator knows every detail of every domain, carries every tool, decides every policy, rewrites every response, and keeps all history, you only renamed the monolith.

A good coordinator should do less.

It needs to understand intent, choose agents, pass minimal context, combine results, detect failures, and know when to ask for help. It should not replicate the internal logic of each domain. It should also not turn every response into an open-ended conversation between agents with no contract.

Useful coordination looks more like routing, contract, and execution control than brainstorming between models.

That requires agent catalogs, clear capability descriptions, input and output schemas, authorization policies, and traces. Without that, "multi-agent" becomes theater: many models talking, little engineering happening.

## How to design a domain-specific agent

I would start with simple questions.

What is the domain? Not "productivity" or "the company." That is too broad. A useful domain is something like ticket triage, email reading, sales proposal generation, PR review, inventory lookup, incident response, or compliance validation.

Which actions can this agent execute? Reading is different from writing. Proposing is different from applying. Simulating is different from changing state.

What is the input contract? If any text works, the agent quickly becomes generic. A good domain accepts natural language, but it should be able to transform it into a small structured intent.

What is the output contract? Free text is good for humans and bad for composition. If another agent depends on the result, the output needs format, evidence, and state.

Which tools are actually necessary? A tool that is too generic invites improvisation. If the agent needs to create tickets, give it `create_ticket`, not `call_http`.

Which evals prove it works? A domain agent without evals is a promise. At minimum, it needs happy paths, ambiguous cases, forbidden cases, tool failures, and known regressions.

What is the budget? Cost, latency, tool calls, retries, loop depth, and maximum context size need to be part of the contract.

## A practical bar

If I were reviewing a domain-specific agent architecture, I would use this list:

1. Does each agent have a domain that fits in one concrete sentence?
2. Are the tools narrow, or is there still a generic tool that is too powerful?
3. Do permissions live outside the prompt?
4. Does the coordinator pass minimal context or dump the entire history?
5. Is each agent's output structured enough for composition?
6. Is identity, budget, and telemetry isolated by agent?
7. Are there domain evals, not just one general system test?
8. Does the system know what to do when a sub-agent fails?
9. Can humans audit which agent decided and which agent executed?
10. Does adding a new domain couple everything back into the main agent?

The last question matters most.

If every new domain increases the central prompt, the central tool list, and the central permission set, you are still doing inheritance. You only put an agent label on top.

## The opposite risk exists

Not every problem needs to become ten agents.

Splitting too early creates latency, coordination cost, premature contracts, and a larger surface for distributed failures. Sometimes one agent with two narrow tools is the right architecture. Sometimes a deterministic workflow solves the problem better than any agent. Sometimes a function with strong validation is enough.

A domain-specific agent is not an excuse to turn every if statement into a multi-agent organization.

The split starts to pay off when real boundaries exist: different permissions, tools, evals, models, costs, ownership, or reuse needs across multiple coordinators.

Without a real boundary, you are just adding network to a local problem.

## What changes

The important change is to stop treating the agent as the final unit of the product.

The real product starts to look like a system of smaller agents, narrow tools, policies outside the prompt, operational memory, domain evals, and a coordinator that knows how to compose without absorbing everything.

That matches the direction of meta harness, harness engineering, and multi-agent orchestration. The isolated agent remains important, but it stops being the place where all complexity lives.

The near future probably will not be a super-agent with every skill in the world. It will be a network of agents small enough to understand, cheap enough to run often, limited enough to trust, and composable enough to solve larger tasks.

The generic agent is good for getting started.

The domain-specific agent is how you keep the beginning from becoming permanent architecture.

## References

- [The Future Is Domain-Specific Agents - Justin Schroeder, StandardAgents](https://www.youtube.com/watch?v=spNAUEgq_A8)
- [BigGo Finance episode summary](https://finance.biggo.com/podcast/340556ea84c18930)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
