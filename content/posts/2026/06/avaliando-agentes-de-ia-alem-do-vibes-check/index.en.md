---
title: 'Evaluating AI Agents Beyond the "Vibes Check": How to Measure What Actually Matters'
description: "Your agent nailed the demo and everyone loved it. But how do you know it actually works? If the answer is 'we tested it and it seemed fine', you are operating in vibes mode. And vibes don't scale."
date: "2026-06-29T10:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - evaluation
    - best-practices
url: /en/avaliando-agentes-de-ia-alem-do-vibes-check/
cover: cover.jpg
cover_alt: "Black telescope pointed at the horizon during the day."
cover_credit_name: "Matthew Ansley"
cover_credit_url: "https://unsplash.com/@ansleycreative"
---

Your agent nailed the demo and everyone loved it. The product manager smiled, the engineering team applauded, and someone already posted on Slack: "this is going to change everything". But how do you _know_ it actually works? If the answer is "we tested it and it seemed fine", you are operating in _vibes_ mode. And vibes don't scale.

If you follow my posts on [Agent Harness](/en/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/), [Tokenomics](/en/tokenomics-agentic-por-que-agentes-de-ia-estouram-sua-fatura-de-api/), and [Multi-Agent Systems](/en/sistemas-multi-agentes-de-ia-quando-usar-como-construir-e-porque-tantos-falham/), you know that building AI agents for production is an engineering discipline, not a vibes game. Today, we tackle what I consider the biggest gap in this ecosystem: **how to evaluate whether your AI agent is truly reliable**.

## The "Vibes-Driven Development" problem

[Hamel Husain](https://hamel.dev/blog/posts/evals/), one of the most respected voices in AI Engineering, put it bluntly:

> "I've found that unsuccessful products almost always share a common root cause: a failure to create robust evaluation systems."

He is not talking about amateur startups. He is talking about sophisticated teams that invest weeks refining prompts and orchestrations, but dedicate zero time to the most important question: _how do I know this works?_

It is a pattern I see repeating with alarming frequency. The team runs a demo with 5 cherry-picked scenarios, all pass, and the agent ships to production. Two weeks later, bug tickets explode. The agent hallucinated a response to a customer, called the wrong tool, or got stuck in a loop burning tokens with no result. Nobody has data to understand _why_ it failed, because nobody instrumented the evaluation.

This is "Vibes-Driven Development": making decisions based on subjective impressions instead of systematic metrics. It is the equivalent of deploying without tests.

## Evals are the new tests

If you are a Software Engineer, you have been through this evolution: there was a time when unit tests were "something for people with time to spare". Then came TDD, CI/CD, and today nobody considers merging without a green suite. Evals for AI agents are at exactly this inflection point.

The analogy is straightforward:

| Software Engineering | AI Engineering |
| --- | --- |
| Unit tests | Outcome evals |
| Integration tests | Trajectory evals |
| Load tests | System metrics (cost, latency) |
| Security tests | Compliance and safety evals |
| CI/CD gates | Eval gates in the pipeline |

The crucial difference is that, unlike deterministic software, agents are _stochastic_. Two runs of the same task can produce different results. This means **the pass rate doesn't need to be 100%, it is a product decision**. But the decision must be informed by data, not vibes.

## The 4 layers of agent evaluation

When I wrote about the [Agent Harness](/en/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/), I explained that agent performance depends on 6 engineering layers. Now, to _measure_ that performance, I propose 4 evaluation layers. Each one answers a different question:

### 1. Outcome: "Did it work?"

The most obvious layer, but also the most treacherous when used alone. You define a task with clear success criteria, run the agent, and verify whether the final state is correct.

The catch is that "correct" for an agent means more than a nice-looking text response. If your agent was supposed to schedule a meeting, the grader cannot just read the confirmation message, it needs to verify that the event _actually_ appeared on the calendar, on the right date, with the right participants. In practice, this is **state-based evaluation**: checking the real world, not the agent's narrative.

Key metrics in this layer:

- **Task Success Rate**: percentage of tasks completed correctly.
- **Grounding/Faithfulness**: are the responses faithful to retrieved data, or did the agent make things up?
- **pass@k**: the probability that _at least one_ of _k_ attempts is correct. Useful for measuring raw capability.
- **retry@k**: success rate within _k_ sequential attempts, stopping at the first correct one. Models the real user experience and the expected cost per success.

The gap between pass@1 (single-shot), pass@k, and retry@k reveals the agent's _reliability_. An agent with 40% pass@1 but 90% pass@5 is capable but inconsistent. You want to invest in making it more deterministic, not just more intelligent.

### 2. Trajectory: "How did it get there?"

This is the layer that separates amateur from professional evaluation. Even when the final result is correct, the _path_ can be wrong.

An agent that fixes a CSS bug may have read 47 irrelevant files, attempted 12 failed edits, and got lucky on the 13th. The result is "correct", but the process is a disaster that cost 500 thousand tokens. Trajectory evaluation inspects every step of the _trace_ (the complete sequence of observations, reasoning, tool calls, and results):

- **Tool selection**: was the right tool called?
- **Correct arguments**: do the parameters passed make sense?
- **Result utilization**: did the agent use the tool's response appropriately?
- **Error recovery**: when something failed, did the agent recover or get stuck in a loop?
- **Plan coherence**: does the sequence of actions follow a progressive logic?

Without trajectory evaluation, you cannot distinguish competence from luck. And luck doesn't scale.

### 3. System: "How much did it cost?"

If you read my post on [Tokenomics](/en/tokenomics-agentic-por-que-agentes-de-ia-estouram-sua-fatura-de-api/), you know that agent costs are stochastic and can vary up to 30x between runs of the same task. The system layer treats the agent like any other production service:

- **Latency**: total execution time (p50, p95, p99).
- **Cost per task**: tokens consumed × price per token. Monitor the distribution, not just the average.
- **Number of tool calls**: a powerful proxy for efficiency. Too many calls may indicate inefficient exploration.
- **Robustness**: does the agent behave well when an external API returns a 500 error? What about when user input is ambiguous or malformed?

These metrics should live in dashboards, not spreadsheets. And they should have alerts.

### 4. Safety and Trust: "Is it safe?"

The layer nobody wants to build, but that will save you when an agent leaks one customer's data to another or ignores a compliance policy:

- **Policy adherence**: did the agent respect permission boundaries, GDPR, and business rules?
- **Red teaming**: deliberate attempts to make the agent misbehave (prompt injection, jailbreaks).
- **Human-in-the-loop scoring**: periodic human review of a sample of executions to calibrate automated graders.

## The LLM-as-Judge pattern

One of the most powerful techniques for evaluating agents at scale is using an LLM as a judge. Instead of writing heuristics for every possible scenario, you define a _rubric_ (evaluation criteria) and ask a strong model (like GPT-5 or Claude Opus) to evaluate your agent's response.

The pattern works like this:

1. **Define the rubric**: "Rate from 1 to 5 whether the agent answered correctly, using only the provided information, without making things up."
2. **Provide context**: user input, available tools, agent response.
3. **Collect the judgment**: the LLM judge returns a score and a justification.

It is scalable, consistent, and surprisingly aligned with human judgment when well calibrated. But it has serious pitfalls:

| Advantage | Corresponding pitfall |
| --- | --- |
| Scales to thousands of evaluations | Can replicate the judge model's biases |
| Consistency in rubric application | Models can hallucinate justifications |
| Cheaper than human evaluation | Risk of _gaming_: agents optimized to please the judge |
| Flexible for custom rubrics | Requires periodic calibration with humans |

A more robust approach is **hybrid**: deterministic graders (code) for objective checks (was the event created? was the file saved?) and LLM-as-Judge for subjective dimensions (was the response clear? was the tone appropriate?). Always with periodic human calibration to ensure the judge is still aligned with reality.

## Tooling: where to start

The evaluation tooling ecosystem has matured significantly. Here is a pragmatic map:

**For code-first teams (Python/pytest):**
[DeepEval](https://github.com/confident-ai/deepeval) is the open-source reference. It offers 50+ ready-made metrics (faithfulness, hallucination, task completion, tool correctness), native pytest integration, and multi-turn trace support. Ideal for those who want to treat evals as tests in CI.

**For observability and traces:**
[Langfuse](https://langfuse.com) is open-source and self-hostable. Excellent for those who need data sovereignty and want to visualize agent traces with dashboards. The metric depth is less than DeepEval, but the combination of both is powerful.

**For the complete cycle (eval + monitoring + collaboration):**
[Braintrust](https://braintrust.dev) offers a free starter plan and covers everything from pre-deploy evaluation to production monitoring, with workflows for observability, datasets, experiments, and failure investigation in traces.

**In practice, mature teams combine at least two:**
- DeepEval for offline evals in CI + Langfuse for production observability.
- Or Braintrust as a unified platform + custom scripts for domain-specific needs.

## A framework to start from scratch

If you have read this far and are thinking "ok, but where do I start?", here is a practical roadmap:

### Step 1: Start with 20 to 50 test cases

Don't try to cover everything. Select real scenarios that represent the most common usage and the most dangerous edge cases of your agent. Each case needs:

- **Input**: what the user asks.
- **Context**: available tools, accessible data.
- **Success criteria**: a precise and unambiguous definition of what "working" means.

### Step 2: Automate grading

For each case, define a grader. Start simple:

- **Deterministic**: was the file created? Was the HTTP status 200? Does field X in the database contain value Y?
- **LLM-as-Judge**: for more subjective dimensions, set up a rubric with examples of high and low scores.

### Step 3: Run with repetition

Remember: agents are stochastic. Run each case at least 3 to 5 times. Record pass@1, pass@k, and retry@k when you have a retry policy. The variance between runs is a signal just as important as the average.

### Step 4: Preserve traces

Save the complete trajectory of every execution. When an eval fails, the trace is your debugging tool. Without it, you are back in vibes land: "I think it failed because of the prompt".

### Step 5: Integrate into CI/CD

Every new feature, prompt change, or model update should go through evals before merging. Real production failures should become new test cases. Your _eval suite_ is a living organism, not a static checklist.

### Step 6: Monitor in production

Pre-deploy evals do not replace observability. Instrument cost logs, latency, success rate, and trace samples in production. Drift happens: what worked with model X can silently degrade when the provider updates to model X.1.

## The discipline that separates demos from products

Hamel Husain keeps pointing at the same idea: in AI Engineering, success depends on shortening the iteration loop. The practical point is direct: you do not iterate quickly without evals.

Building agents is exciting. Making demos that impress is easy. But putting an agent into production and _knowing_ that it is reliable, efficient, and safe? That requires the same discipline that software engineering took decades to develop with automated testing.

The good news is that you don't need to wait decades. The tooling exists, the frameworks are mature, and the knowledge is available. What is missing is the decision to treat evaluation as essential infrastructure, not as a "nice to have" you get to "when there's time".

If your agent doesn't have evals, it doesn't have quality. It has luck. And luck has an expiration date.
