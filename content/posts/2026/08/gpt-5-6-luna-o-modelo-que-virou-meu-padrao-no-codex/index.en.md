---
title: "GPT-5.6 Luna: the model that became my default in Codex"
description: "After nearly 10 billion tokens in Codex, why GPT-5.6 Luna became my default model: cost, performance, context, and limits."
date: "2026-08-26T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - codex
    - llm
    - agent
    - developer-experience
    - cost-management
url: /en/gpt-5-6-luna-o-modelo-que-virou-meu-padrao-no-codex/
cover: cover.jpg
cover_alt: "Night landscape under moonlight, with a trail of light crossing the mountains."
cover_credit_name: "Jonathan Barreto"
cover_credit_url: "https://unsplash.com/photos/landscape-photography-of-green-trees-under-moon-EkjHd-r_jF0"
---

Some models impress you with their first answer. Others change the way you work after weeks of use.

For me, GPT-5.6 Luna belongs to the second category.

Over the last month, I have used Luna extensively with Codex, reaching nearly 10 billion tokens. That number is not a controlled benchmark and should not be read as a universal productivity measurement. It is simply the amount of work that happened to pass through this model in my workflow.

Even so, after that many tasks, tests, fixes, and reviews, my conclusion is clear: Luna is my default model today.

Not because it is the smartest model for every task. It is not. Sol remains the choice for the hardest problems, and Terra can be a better middle ground in some situations. What makes Luna special is something else: it provides enough intelligence, enough speed, and a low enough cost to keep working.

## The name hides the important decision

GPT-5.6 is not one capability. The family has three models with different roles: Sol is the frontier model, Terra balances intelligence and cost, and Luna is designed for fast, repeatable, high-volume work.

OpenAI's [model documentation](https://developers.openai.com/api/docs/models/gpt-5.6-luna) compares Luna with the nano tier in earlier GPT-5 families. That does not mean it is merely a small model with fewer visible parameters. It means the design prioritizes how much useful work can be done per unit of cost.

The most relevant characteristics are:

| Characteristic | GPT-5.6 Luna |
| --- | --- |
| API context window | 1.05 million tokens |
| Maximum output | 128K tokens |
| Reasoning effort | `none`, `low`, `medium`, `high`, `xhigh`, and `max` |
| Input and output | Text; image input |
| Knowledge cutoff | February 16, 2026 |
| Fine-tuning | Not supported |

The Responses API page also lists function calling, structured outputs, web search, file search, code interpreter, hosted shell, apply patch, skills, computer use, MCP, and tool search. In Codex, that matters more than an isolated capability checklist: the model has to read a repository, choose an action, run a tool, interpret the result, and continue.

## Price changes the experience, not just the bill

At launch, Luna cost $1 per million input tokens and $6 per million output tokens. On July 30, OpenAI cut its price by 80%. The current API table looks like this:

| Model | Input | Cached input | Output |
| --- | ---: | ---: | ---: |
| GPT-5.6 Luna | $0.20 | $0.02 | $1.20 |
| GPT-5.6 Terra | $2.00 | $0.20 | $12.00 |
| GPT-5.6 Sol | $4.00 | $0.40 | $20.00 |

These values are per million tokens and come from OpenAI's current [model comparison page](https://developers.openai.com/api/docs/models/compare). There is an important caveat: requests with more than 272K input tokens enter a long-context tier with different multipliers. Actual cost also depends on the mix of input, output, cache, tools, and processing mode.

For a sense of scale, if my nearly 10 billion tokens were billed directly through the API:

- 10 billion uncached input tokens would cost about $2,000;
- 10 billion output tokens would cost about $12,000;
- 10 billion cached input tokens would cost about $200.

That is not an estimate of my bill. I use Luna inside Codex, and subscription usage is not the same thing as an API invoice. OpenAI has said that subscription prices and quota budgets did not change, while Terra and Luna now consume fewer credits. Without separating input, output, cache, and plan rules, turning "10 billion tokens" into a dollar amount would be guesswork.

The practical effect of the price is still enormous. A coding agent does not make one call and finish. It reads files, searches references, runs tests, receives errors, fixes them, runs everything again, and reviews its own diff. When each iteration is cheap, it becomes viable to let the agent investigate one more hypothesis or run one more check.

The value is not only the price per token. It is the lower friction to try, measure, and try again.

## What the benchmarks say

OpenAI's published numbers tell a more interesting story than "Luna is the best model." On some evaluations it beats GPT-5.5. On others it is slightly behind. The pattern is close enough that price becomes decisive for many workflows.

| Evaluation | GPT-5.6 Luna | GPT-5.5 | Quick reading |
| --- | ---: | ---: | --- |
| Agents' Last Exam | 50.3% | 46.9% | Above GPT-5.5 |
| GDPval-AA v2 | 1,591.8 Elo | 1,493.7 Elo | Above GPT-5.5 |
| SWE-Bench Pro | 62.7% | 59.4% | Above GPT-5.5 |
| DeepSWE v1.1 | 67.2% | 67.0% | Practically tied |
| Terminal-Bench 2.1 | 84.7% | 85.6% | Very close |
| Artificial Analysis Coding Agent Index | 74.6 | 76.4 | Lower, but competitive |
| BrowseComp | 83.3% | 84.4% | Very close |

These results come from the [GPT-5.6 launch evaluation table](https://openai.com/index/gpt-5-6/). As always, they are provider-published results using specific harnesses and configurations. They are useful for forming hypotheses, not for skipping evaluation on your own work.

OpenAI's [builder's guide](https://openai.com/index/builders-guide-to-gpt-5-6/) offers an even clearer cost comparison. At launch, Luna at Extra High scored 84.04% on BrowseComp for $1.33, while GPT-5.5 on the same benchmark scored 84.36% for $33.27. The quality difference was small. The cost difference was not.

My conclusion is not that Luna beat Sol. It is that, for a meaningful part of the work, the gap is small enough that several cheap attempts are better than one expensive attempt.

## Why it works so well in Codex

Codex changes the unit of work. In a chat, I mostly evaluate the quality of the answer. In a coding agent, I need to evaluate whether it can turn intent into a verifiable change.

That is where Luna earned its place in my workflow.

### 1. Lower cost reduces friction

The biggest advantage is not a spectacular answer. It is being able to ask for an investigation, let the agent inspect the code, run a test, and make a second pass without treating every call as an expensive event.

For routine tasks, the ability to continue matters as much as the quality of the first attempt. An agent that can test one more hypothesis may be more useful than a theoretically stronger model that has to be interrupted because of the budget.

### 2. It is strong when the work is well defined

Luna makes the most sense when the objective, scope, and definition of done are clear: locate an implementation, add tests, fix a regression, update a dependency, perform a bounded refactor, review documentation, or turn a set of results into a summary.

These tasks still require judgment, but they do not require the model to invent the entire problem. The repository, tests, and acceptance criteria provide part of the reasoning.

### 3. The harness carries part of the intelligence

It is tempting to compare models as if they were only text boxes. In Codex, the result also depends on context, tools, permissions, skills, memory, compaction, repository instructions, and test quality.

The official [model guidance](https://developers.openai.com/api/docs/guides/latest-model) recommends Luna for efficient, high-volume workflows. The [Codex subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents) is even more specific: Luna is intended for fast, narrowly scoped, repeatable, or high-volume agents.

That is the argument I developed in my [earlier post, "Meta Harness: the missing layer in agent engineering"](/en/meta-harness-a-camada-que-falta-na-engenharia-de-agentes/). A well-made harness makes Luna perform better in practice because it organizes context, limits scope, gives the model tools to act, and requires checks before accepting a change. The model does not become more intelligent in the strict sense, but it can apply the capability it already has more effectively.

That matches how I like to work. I let the model handle exploration and mechanical execution, while keeping boundaries, validation commands, and the expected result explicit.

### 4. Quality shows up as cost per accepted change

The number I care about is not how many tokens the model can generate. It is how much it costs to reach a change that passed its tests, can be reviewed, and deserves to continue existing.

If Luna delivers a correct change in four cheap iterations, it may be more useful than a stronger model that gets close in one attempt but consumes the entire budget when it has to correct its first interpretation.

That is why nearly 10 billion tokens matter to my evaluation. Not because volume proves quality. Because a model only becomes a primary tool when the cost allows it to participate in almost every stage of the work.

## How to choose reasoning effort

Luna is not one fixed configuration. The effort parameter changes how much work the model does, and it changes latency and usage too.

My practical rule would be:

1. Use `low` when the task is direct and speed is the main factor.
2. Start with `medium` for normal work and as a comparison point.
3. Use `high` or `xhigh` when there is complex logic, hypotheses to verify, or edge cases to trace.
4. Reserve `max` for tasks where longer exploration could materially change the result.

More reasoning does not turn a poor specification into a good one. If the agent does not know which file it may change, which test proves correctness, or which behavior must not change, increasing effort may only produce a longer investigation.

The same applies to subagents. [Codex documents](https://learn.chatgpt.com/docs/agent-configuration/subagents) that when a model or effort is not configured, a subagent inherits the parent's values. If the goal is to save cost by using Luna for a worker, that intention needs to be explicit and should be verified in the result. A name such as "cheap worker" does not guarantee that the process actually used Luna.

## A large context window is not perfect memory

1.05 million tokens is an impressive capacity, but a large window does not guarantee that every piece of information will remain equally relevant or be retrieved correctly.

In the same official table, Luna scored 41.3% on MRCR v2 eight-needle retrieval at 256K to 512K tokens and again 41.3% at 512K to 1M. GPT-5.5 scored 81.5% and 74% in those two ranges. This benchmark measures one kind of long-context retrieval, not the whole programming experience, but it is a good reminder: putting more text in the conversation is not the same as giving the agent more understanding.

There is also a difference between the API specification and the Codex environment. The [Codex CLI 0.144.6 notes](https://learn.chatgpt.com/docs/changelog) recorded a correction of the GPT-5.6 models' context windows to 272K tokens. The client, authentication channel, and compaction rules can evolve, so the value shown by the session and the moment it compacts matter more to real work than repeating the number on the API page.

I try not to dump the entire repository into context just because I can. I prefer short instructions, split investigations, summarized results, and returning only decision-changing information to the main agent. Context is working memory, not an infinite warehouse.

## Where I would not choose Luna

Being my default does not mean being the right model for everything.

I would choose Terra or Sol when the task is highly ambiguous, involves an architectural decision, requires security investigation, depends on a delicate synthesis, or has a high cost of failure. I would also not treat Luna as a replacement for human review on irreversible changes or product decisions.

There are objective limits: the model page does not list audio or video modalities and does not offer fine-tuning. Long context requires care. And workflows with many subagents consume more tokens because each agent does its own model and tool work.

There are also reports that differ from my experience. In an [anecdotal community discussion](https://www.reddit.com/r/hermesagent/comments/1uvk24n/thoughts_after_using_gpt_56_luna_for_48_hours/), one user described Luna as smart but slow at high effort, with a tendency to take several small iterations and occasionally ignore explicit instructions. That is not a general measurement. It is still a useful warning: low cost does not remove the need to watch loops, forgotten instructions, and degraded context.

The model is not the whole system either. A [recent paper on harness scaling](https://arxiv.org/abs/2608.15089) reported raising GPT-5.6 Luna from 76.7% to 85.4% on Terminal-Bench 2.1 using a runtime and a persistent runbook. That is not an official leaderboard result and is not directly equivalent to OpenAI's figures, but it reinforces an important idea: the model is only one part of performance.

## What I learned after 10 billion tokens

The first lesson is that price is an operational capability. When the cost allows more cycles of reading, execution, and verification, it changes what is worth delegating.

The second is that a "default model" does not have to mean a "single model." Luna can be the base of the workflow, while Terra or Sol step in when ambiguity, risk, or depth crosses the limit that the cost-optimized tier can handle well.

The third is that the best benchmark is an accepted change per unit of cost. Leaderboards help decide what to test. They do not tell you which model understands your repository, conventions, tests, and tolerance for rework.

That is why I now choose GPT-5.6 Luna with confidence for everyday work in Codex. It is not always the most brilliant person in the room. It is the colleague I can call for almost anything, who works quickly, costs little, and still produces results good enough to deserve a serious review.

For me, that balance is more valuable than an isolated capability demonstration. The most useful intelligence is the intelligence you can afford to keep working.

## Sources

- [GPT-5.6: Frontier intelligence that scales with your ambition](https://openai.com/index/gpt-5-6/)
- [Advancing the price-performance frontier with GPT-5.6](https://openai.com/index/advancing-the-price-performance-frontier-with-gpt-5-6/)
- [GPT-5.6 Luna Model](https://developers.openai.com/api/docs/models/gpt-5.6-luna)
- [Compare models](https://developers.openai.com/api/docs/models/compare)
- [Model guidance for GPT-5.6](https://developers.openai.com/api/docs/guides/latest-model)
- [The builder's guide to GPT-5.6](https://openai.com/index/builders-guide-to-gpt-5-6/)
- [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [ChatGPT and Codex changelog](https://learn.chatgpt.com/docs/changelog)
- [StateM: Reaching 95.3% Raw Accuracy on Terminal-Bench 2.1 via Harness Scaling](https://arxiv.org/abs/2608.15089)
- [GPT-5.6 Luna benchmark review](https://layerlens.ai/blog/gpt-5-6-benchmark-review-sol-terra-luna)
- [Community discussion about using GPT-5.6 Luna](https://www.reddit.com/r/hermesagent/comments/1uvk24n/thoughts_after_using_gpt_56_luna_for_48_hours/)
