---
title: Excessive Agency Is a Reliability Bug, Not Only a Security Risk
description: "When an agent is allowed to act too broadly, the risk is not only leakage or abuse. It also becomes hard to operate: it works outside scope, repeats actions, burns budget, and fails without a clean way back."
date: "2026-07-27T08:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - security
    - reliability
    - governance
url: /en/excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/
cover: cover.jpg
cover_alt: "Open padlock resting on a computer keyboard."
cover_credit_name: "Sasun Bughdaryan"
cover_credit_url: "https://unsplash.com/@sasun1990"
---

Whenever we talk about excessive agency in AI agents, the conversation quickly becomes a security conversation. That makes sense. An agent with too many tools, too many permissions, and too much autonomy is a neat way to turn a prompt failure into a real action in the world.

But the security framing leaves half of the problem out.

Excessive agency is also a reliability bug. Even when there is no attacker, no leakage, and no deliberate abuse, an agent with too much room to act becomes hard to operate. It can repeat an action, burn budget without noticing, change the right resource at the wrong time, execute a task that is only adjacent to what you asked for, or fail halfway through without a recoverable state.

This is not an implementation detail. It is an engineering boundary.

## The security framing is correct, but incomplete

The OWASP Top 10 for LLM Applications names excessive agency as an explicit risk. The 2025 list is still the reference for LLM applications in general, but OWASP's 2026 material opened a more specific track: the Top 10 for Agentic Applications, focused on systems that plan, use tools, carry identity, and execute actions with some degree of autonomy.

That update changes the center of the conversation. The question is no longer only "did the model produce a dangerous response?" It also becomes "could the agent turn a bad decision into a side effect?" That is why OWASP's agentic material talks about risks tied to diverted goals, misused tools, abused identity or privilege, cascading failures, poorly calibrated human trust, and agents that move beyond expected boundaries.

LLM06:2025 remains useful because it names the root cause directly: excessive functionality, excessive permissions, or excessive autonomy. The 2026 Agentic Top 10 makes clearer what that becomes in real systems.

That framing is useful because it forces a question many agent architectures avoid:

> What can this system do when the model is wrong?

Not when the attacker is brilliant. Not when the prompt is obviously malicious. When the model simply misreads intent, trusts a bad observation too much, or chooses a tool that looked reasonable in context.

That is where security and reliability meet.

OWASP's Q1 2026 exploit roundup reinforces the same point. One case describes an email agent that was supposed to suggest what to delete or archive, but started deleting messages directly and ignored stop commands sent from a phone. There was no external attacker. The problem was more basic: destructive permission, weak confirmation, and a poor recovery path.

## A secure agent can still be unreliable

Imagine an internal support agent. It authenticates correctly, uses valid credentials, only calls corporate APIs, and never exposes data outside the company. From a classic security point of view, it might look acceptable.

Now give it permission to:

* read tickets;
* edit status;
* apply credits;
* change account metadata;
* send customer replies;
* close support cases;
* retry calls when an API fails.

None of these actions needs to be malicious to cause damage.

The agent can apply a credit to the wrong customer because it summarized a ticket poorly. It can close an entire queue because it interpreted "resolve duplicate cases" as "close all similar cases". It can try the same operation three times after a timeout and create three side effects. It can pass a generic approval at the beginning and then execute a sequence of actions no one really reviewed.

Notice the important part: none of this requires a jailbreak. The system can be authenticated, authorized, and still hard to trust.

The bug is not only "the agent can be attacked". The bug is "the agent can act beyond what the product can absorb when it is wrong".

## Agency is part of the failure model

In traditional software, we usually model failures in terms of exceptions, timeouts, downtime, and invalid data. Agents add another failure mode: the plausible but wrong decision.

The model chooses a plausible tool. The arguments look coherent. The text response sounds confident. But the action should not have happened in that context.

If the system allows broad, repeatable, irreversible action, you have turned probabilistic uncertainty into an operational incident. The problem is no longer "the model was wrong". It is "the environment accepted the mistake as an executable command".

That is why I prefer treating agency as an explicit reliability dimension:

* **Breadth:** how many kinds of action can the agent execute?
* **Frequency:** how many times can it try before it stops?
* **Scope:** which resources, accounts, regions, or customers can it touch?
* **Reversibility:** is there a way back when the action was wrong?
* **Observability:** can someone reconstruct what happened without trusting the agent's narrative?

If these questions do not have clear answers, the agent is not production-ready. It may pass the happy-path tests, but it still lacks a reliable execution model.

## Control has to live outside the prompt

A common response is to try to solve this with an instruction:

> "Be careful before executing destructive actions."

That is better than nothing, but it is not control. It is a suggestion to the least deterministic component in the system.

The important boundaries need to live in the harness, credentials, APIs, orchestrator, and downstream systems. The prompt can explain the policy. It should not be the policy.

In practice, this means designing the agent like any other system that creates side effects.

### Tool permissions

Tools should be narrow. An agent that needs to open a ticket does not need a generic `call_http` tool. It needs `create_ticket` with a small schema, strong validation, and predictable behavior.

The same applies to shells, databases, and cloud platforms. Open-ended tools are comfortable during prototyping, but they create a large surface for mistakes. In production, the question should be: what is the smallest useful action I can expose?

### Scoped credentials

Limiting the tool is not enough if the credential behind it remains broad.

Use minimal scopes, user identity when appropriate, short-lived tokens, and separate permissions for reads and writes. A recommendation agent that only needs to query products should not carry a credential that can also update prices.

This improves security, of course. It also improves reliability because it shrinks the maximum size of the accident.

### Dry-run as the first path

For expensive, destructive, or hard-to-reverse actions, the default mode should be simulation.

The agent builds the plan, calculates the diff, shows which resources would change, and only then executes. This dry-run needs to be produced by the system, not merely described by the model. A nice textual plan is not a substitute for a real state check.

### Approval at the right point

Human-in-the-loop only works when approval is close to the side effect.

Approving "the agent can resolve this incident" is too broad. Approving "scale deployment `checkout-api` from 8 to 12 replicas in cluster `prod` for the next 30 minutes" is much better. The approval should show the target, action, reason, diff, and rollback path.

### Idempotency and deduplication

Agents repeat. APIs fail. Timeouts lie.

Every action with a side effect should carry an idempotency key or an equivalent mechanism. If the agent retries, the system needs to know whether it is repeating the same intention or creating a new operation.

Without that, retry becomes a polite way to duplicate problems.

### Budget limits

Budget is not only money. It is time, tool calls, tokens, changes per execution, processed items, and loop depth.

A reliable agent should have explicit limits and decent behavior when it reaches them. Stop, explain the current state, and ask for intervention. That is much better than continuing until the platform enforces a hard limit.

### Audit trail

After an execution, you should be able to answer without guessing:

* who asked;
* what the objective was;
* which tools were called;
* with which arguments;
* which responses came back;
* which side effects were produced;
* which approvals existed;
* which rollback was available.

If the only explanation is a summary generated by the agent itself, you do not have an audit trail. You have a story.

### Rollback path

Not every action is reversible. That is exactly why the question has to be asked before deployment.

When rollback is not possible, use compensation, snapshots, review queues, or smaller limits. The mistake is not allowing irreversible actions. The mistake is allowing irreversible actions with the same friction as a read-only query.

## The practical bar

When I review an agent design, I try to leave the abstract discussion and ask boring questions:

1. What can it do without approval?
2. Which identity shows up in downstream systems?
3. What is the largest possible damage in a single run?
4. What happens if the same action is repeated?
5. What happens if the model chooses the right tool with the wrong arguments?
6. Is there a dry-run for actions with side effects?
7. Is there a clear limit for cost, time, and number of tool calls?
8. Can I reconstruct the execution from structured logs?
9. Is there a tested rollback or compensation path?
10. Does the agent fail stopped or fail acting?

That last question is the most important one.

Reliable systems prefer to stop when they do not know. Systems with excessive agency tend to continue, because continuing looks like progress. In agents, that difference is huge.

## Less agency is not less automation

There is an emotional resistance here. Many people interpret limits as a defeat: "if I need to approve everything, then I do not have an agent".

Not quite.

The goal is not to turn the agent into an expensive form. The goal is to grant autonomy where mistakes are cheap and add friction where mistakes are expensive.

An agent can read, classify, summarize, propose, correlate, and prepare changes with a lot of freedom. The boundary changes when it is about to modify state, spend meaningful budget, talk to customers, delete data, move money, change permissions, or touch production.

That split feels like bureaucracy until the day you need to explain why a model executed 200 actions that were correct in shape and wrong in intent.

## The right question

"Can we trust the model?" is too broad to be useful.

The better question is:

> Is the execution path narrow, observable, and recoverable enough to accommodate a fallible model?

If the answer is no, you do not only have a security risk. You have a reliability bug waiting for a bad input, an ambiguity, or an unlucky retry.

Good agents are not the ones that can do everything. They are the ones that can do the right thing inside a well-designed action space, with limits that keep working when the model is wrong.

## References

* [OWASP Top 10 for LLMs and Gen AI Apps 2025](https://genai.owasp.org/llm-top-10/)
* [OWASP LLM06:2025 Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/)
* [OWASP Top 10 for Agentic Applications for 2026](https://genai.owasp.org/initiatives/agentic-security-initiative/)
* [OWASP GenAI Exploit Round-up Report Q1 2026](https://genai.owasp.org/2026/04/14/owasp-genai-exploit-round-up-report-q1-2026/)
