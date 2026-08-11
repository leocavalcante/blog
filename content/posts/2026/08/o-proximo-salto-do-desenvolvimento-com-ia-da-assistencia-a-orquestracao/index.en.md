---
title: "The next leap in AI software development: from assistance to orchestration"
description: "The next wave is not just writing code with a copilot. It is coordinating supervised agents, context, tests, and boundaries across the entire development lifecycle."
date: "2026-08-11T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - software-engineering
    - developer-experience
    - reliability
url: /en/o-proximo-salto-do-desenvolvimento-com-ia-da-assistencia-a-orquestracao/
cover: cover.jpg
cover_alt: "Laptop displaying source code on a desk, representing the transition from coding assistance to agent orchestration."
cover_credit_name: "Bayu Syaits"
cover_credit_url: "https://unsplash.com/photos/laptop-and-phone-on-a-desk-with-coding-software-open-oYzjGQ7LCVE"
---

When someone asks what the next trend in AI and software development will be, the easiest answer is to point to another model, another editor, or another promise of code generated from a sentence.

Looking at adoption, research, and real usage, the more important change looks less cinematic: development will stop using AI only to write code and start using it to **coordinate verifiable changes across the entire delivery lifecycle**.

This is not the end of the developer. It is a change in the unit of work. The center of gravity moves away from the line of code or the function and toward the supervised task: understand a problem, propose a change, implement it, test it, open a pull request, and leave enough evidence for someone to decide whether it should move forward.

## The ticket became the unit of work

A traditional copilot suggests the next line. A coding agent receives a larger goal: fix a bug, add a feature, update a dependency, or investigate a pipeline failure.

That difference looks like an interface detail, but it changes the workflow. The agent has to navigate the repository, choose files, run commands, interpret errors, and decide when the task is done.

The adoption signals already point in this direction. In [Stack Overflow’s 2026 pulse survey](https://stackoverflow.blog/2026/05/27/agents-on-leash-agentic-ai-remains-mostly-single-agent-and-monitored-at-work/), agent use at work rose from 31% to 59% in one year. Yet 63% of respondents still rarely or never let an agent operate completely on its own. Most workflows continue to use one agent at a time, with human monitoring.

That matters because two ideas are often treated as synonyms:

- **delegation:** the agent executes part of the work;
- **autonomy:** the agent chooses goals, boundaries, and consequences without meaningful supervision.

The first is becoming routine. The second is not yet the default operating model.

## The agent is not autonomous. It is supervised

An [analysis from Anthropic](https://www.anthropic.com/research/claude-code-expertise?level=0) of roughly 400,000 Claude Code sessions helps show what this collaboration looks like. In a typical session, the person makes most planning decisions while the agent makes most execution decisions.

In other words, the person decides what to build, which problem matters, and what counts as done. The agent decides which files to change, which commands to run, and how to turn intent into a concrete change.

That is more realistic than the image of an engineer pressing a button. Supervision does not disappear; it moves. Instead of following every character, the developer has to define context, boundaries, acceptance criteria, and stopping points.

The agent becomes an asynchronous collaborator with bounded tools. It can work while the person does something else, but it has to return a result that can be inspected: diff, tests, logs, decisions, open questions, and known risks.

## The next bottleneck is context

The more independently an agent works, the less an isolated prompt can explain. It needs to know how the repository is organized, which commands are trustworthy, which architectural decisions must not be broken, which dependencies are allowed, how to run tests, and when a change requires human approval.

That is more than an instruction. It is the agent’s operating environment.

This is why **context engineering** is likely to become a more important discipline than prompt engineering. The work is selecting and maintaining the right context for each step: documentation, code, memory, task state, tools, policies, and evidence.

The shift is already visible in the products. [GitHub Copilot coding agent began supporting `AGENTS.md`](https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/) files at the repository root or in subdirectories, alongside other instruction formats. The file is not magic. It simply makes explicit something mature teams already do for people: document how the system works and how a change should be validated.

In long-running tasks, the history itself becomes a problem. The [paper published in the Findings of ACL 2026](https://aclanthology.org/2026.findings-acl.1032/) describes how context can grow too large, suffer semantic drift, and degrade an agent’s reasoning. Its proposal treats context management as an actionable tool instead of an infinite sequence of messages.

A repository prepared for agents should answer, in a readable and verifiable way:

- what this project does and does not do;
- which commands install, test, format, and validate a change;
- which parts of the system are sensitive;
- which conventions do not appear in the compiler;
- which actions the agent may perform on its own;
- how it should report uncertainty, failure, and incomplete work.

The instruction file is only the entry point. The real context includes the quality of the code, tests, documentation, and interfaces the agent can access.

## Review becomes the product

Writing code is getting cheaper. Knowing whether the code solves the right problem remains expensive.

The [2025 DORA report](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report?e=48754805) found near-universal AI use among respondents and broad perceptions of productivity gains. At the same time, adoption had a positive relationship with throughput and product performance, but a negative relationship with stability when teams lacked automated tests, version control, and fast feedback loops.

This is the part that disappears from announcements. AI can increase the number of changes produced. Without a control system, it also increases the number of changes nobody managed to understand properly.

Developers are signaling something similar. In the [2025 Stack Overflow AI survey](https://survey.stackoverflow.co/2025/ai), 87% of respondents expressed concern about agent accuracy and 81% about data security and privacy. The central question is no longer “can AI generate something?”. It is “how much does it cost to prove that the result is safe, correct, and sustainable?”.

That proof has to be produced by the system, not just by the author’s confidence. When applicable, an agent-generated pull request should include:

- the plan that guided the change;
- the changed files and why each one changed;
- tests that ran and tests that could not run;
- static analysis, security checks, and dependency impact;
- decisions left for human review;
- signals of uncertainty or behavior that has not been observed yet.

This changes review. The reviewer does not have to reread every line as if it were written in isolation. They need to evaluate the evidence, look for gaps, and decide whether the remaining risk is acceptable.

## There is no universal productivity number

Productivity research is still contextual, and that is useful information.

Microsoft field experiments with 4,867 developers found a 26% increase in completed tasks when participants had access to a coding assistant. METR’s controlled study with experienced developers working on open-source projects observed tasks taking 19% longer with early-2025 AI tools. In a later update, METR said its newer data was weak because of selection effects, although developers were probably getting more speedup from newer tools.

The studies do not measure exactly the same thing. One uses code-completion assistants in enterprise environments; the other observes experienced maintainers working in repositories they already know well. The right conclusion is not to pick the percentage that confirms a team’s preference.

The conclusion is that productivity is not a fixed property of the tool. It depends on the task, domain knowledge, context quality, experience with the agent, and the cost of reviewing what it produces.

If a team wants to know whether it got faster, it needs to measure its own system: time to an accepted change, reopened bugs, review rework, post-deploy failures, cost per change, and stability. Lines of code, commit counts, and accepted suggestions are easy signals, but they are not the outcome.

## Multi-agent systems are a consequence, not the starting point

Anthropic’s [2026 agentic coding trends report](https://resources.anthropic.com/ty-2026-agentic-coding-trends-report) predicts the evolution from single agents to coordinated teams, long-running agents, and automated review at scale. The direction makes sense: a complex task can be split between agents specialized in implementation, testing, security, documentation, and operations.

But practice is still behind the forecast. Stack Overflow’s survey shows that most people work with one agent at a time, while a minority coordinate specialized or overlapping agents.

That suggests an order of investment. First, make one agent execute one narrow, verifiable task well. Then add specialization where the bottleneck is clear. A group of agents sharing bad context only distributes confusion faster.

The orchestration problem is not just calling several models. It is coordinating state, identity, permissions, edit conflicts, token budgets, failure recovery, and responsibility for the result.

## The developer’s work becomes broader

It is tempting to conclude that if AI writes code, the developer’s value disappears. The data points to a different change.

In Anthropic’s analysis, sessions with stronger domain knowledge were more likely to succeed. A person does not need to master every implementation detail, but they do need to understand the problem, recognize a plausible solution, and notice when the agent is following the wrong interpretation.

A [Google study of software-agent behavior](https://research.google/pubs/towards-ai-as-a-collaborative-partner-a-taxonomy-of-ai-agent-behavior-in-software-engineering/) reached a similar conclusion through a different route. After analyzing developer-written rules and interviewing experienced professionals, the authors organized expectations into four groups: following standards and processes, ensuring quality and reliability, solving problems, and collaborating with the developer.

That describes the new profile well. Developers need to write specifications, decompose problems, design systems, create verification, limit agency, interpret telemetry, and make product decisions. Coding remains important, because understanding the material makes delegated work easier to review. But writing every line is no longer the only way to contribute.

The developer does not become a prompt manager. They become responsible for the system that turns intent into a reliable change.

## How to prepare now

There is no need to wait for a perfect agent architecture. A few practices already pay off with simple tools:

1. **Turn the repository into a contract.** Keep instructions, architectural decisions, commands, conventions, and the definition of done in versioned files. A short `AGENTS.md` with links to the sources of truth is more useful than a huge, stale prompt.
2. **Delegate verifiable tasks.** Start with fixes, tests, small migrations, documentation, and refactorings with clear criteria. Do not hand an ambiguous product decision to an agent and expect it to invent the missing context.
3. **Give minimum agency.** The agent may read broadly, but it should write in a branch, use narrow tools, and encounter blockers before touching production. Broad permission is not the same as capability.
4. **Turn acceptance into automation.** Tests, linters, type analysis, security scanners, contract tests, and evaluation scenarios should run as part of the task. The agent needs feedback it can use to correct its own work.
5. **Measure accepted changes, not activity.** Track delivery time, failures, rollbacks, escaped defects, review rework, and cost. The goal is more reliable outcomes, not more text produced by the team.
6. **Keep human judgment where there is commitment.** Product, architecture, security, privacy, and irreversible changes need an identifiable owner. Automation can prepare the decision; it should not hide who made it.

## The risk is building more software than we can maintain

When code becomes cheap, scarcity moves elsewhere. The rare resource becomes qualified attention: understanding the domain, setting boundaries, reviewing evidence, and caring for what will still exist after the initial excitement.

That is why I would not bet on “vibe coding” as an engineering operating model for critical systems. It is excellent for exploring an idea, building a prototype, and discovering questions. A product that has to survive change still needs context, tests, ownership, and the ability to explain decisions.

The next trend is not a machine replacing the developer. It is an environment where a developer can coordinate more work without losing track of why each change exists or how to know whether it is correct.

If an agent opened a pull request in your repository tonight, would it know how to prove that the change was ready?

## References

- [Agents on a leash: Agentic AI remains mostly single-agent and monitored at work](https://stackoverflow.blog/2026/05/27/agents-on-leash-agentic-ai-remains-mostly-single-agent-and-monitored-at-work/)
- [Agentic coding and persistent returns to expertise](https://www.anthropic.com/research/claude-code-expertise?level=0)
- [2026 Agentic Coding Trends Report](https://resources.anthropic.com/ty-2026-agentic-coding-trends-report)
- [2025 DORA Report: State of AI-Assisted Software Development](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report?e=48754805)
- [AI: 2025 Stack Overflow Developer Survey](https://survey.stackoverflow.co/2025/ai)
- [Towards AI as a Collaborative Partner](https://research.google/pubs/towards-ai-as-a-collaborative-partner-a-taxonomy-of-ai-agent-behavior-in-software-engineering/)
- [Context as a Tool: Context Management for Long-Horizon SWE-Agents](https://aclanthology.org/2026.findings-acl.1032/)
- [The Effects of Generative AI on High-Skilled Work](https://www.microsoft.com/en-us/research/publication/the-effects-of-generative-ai-on-high-skilled-work-evidence-from-three-field-experiments-with-software-developers/)
- [We are Changing our Developer Productivity Experiment Design](https://metr.org/blog/2026-02-24-uplift-update/)
