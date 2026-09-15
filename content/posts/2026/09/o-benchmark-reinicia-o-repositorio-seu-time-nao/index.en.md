---
title: "The benchmark resets the repository. Your team does not"
description: "Coding agents look more capable when every task starts from a clean checkout. New benchmarks show the cost that appears when patches, decisions, and technical debt carry into the next job."
date: "2026-09-14T19:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - software-engineering
    - evaluation
    - code-review
    - maintainability
url: /en/o-benchmark-reinicia-o-repositorio-seu-time-nao/
cover: cover.jpg
cover_alt: "Narrow path through a snow-covered forest."
cover_credit_name: "Luise and Nic"
cover_credit_url: "https://unsplash.com/photos/a-path-through-a-snowy-forest-with-tall-trees-M2Prs8jBNJ0"
---

Every benchmark must decide what persists from one task to the next.

In traditional coding-agent evaluation, the answer is usually: nothing.

The agent receives an issue, opens the repository, writes a patch, and passes the tests. Then the container returns to the initial commit, the conversation history disappears, and another problem starts on a clean base, usually validated by humans.

At work, the second issue starts from the code left by the first one.

That reset looks like a laboratory detail. But it changes what is being measured. Solving a task and maintaining a system are different abilities.

When I wrote about [evaluating agents beyond the vibes check](/en/avaliando-agentes-de-ia-alem-do-vibes-check/), I covered outcome, trajectory, cost, and safety. Recent research adds a question that comes before all four: how long must the result remain correct?

**If the agent will work repeatedly in the same repository, the evaluation must make it inherit its own decisions**.

Measuring whether the current patch is green is not enough. We need to measure whether the state left today remains a usable base tomorrow.

## The reset is a measurement choice

Benchmarks such as SWE-bench made an important contribution. They moved code evaluation beyond autocomplete and into real repositories, issues, tools, and executable test suites.

Isolating each task makes sense when comparing models. A clean checkout reduces noise. The same bug starts from the same commit for every candidate. A previous failure cannot contaminate the next measurement.

The problem appears when we turn that experimental choice into an operational promise.

A score on isolated tasks answers a narrow question:

> Given a validated repository and an issue, what is the chance that the agent produces a patch that passes this suite?

A team delivering software needs to answer another:

> After a sequence of changes made by the agent, does the repository still preserve behavior, architecture, and room for the next change?

The reset does not make the benchmark bad. It makes extrapolation dangerous.

Every reset removes exactly what maintenance accumulates: local decisions, incomplete abstractions, new tests, dependencies between files, and technical debt. The benchmark sees a patch. The team inherits a trajectory.

## Three issues are enough to change the score

[ChainSWE](https://arxiv.org/abs/2607.02606), submitted in July and revised in September 2026, was built to observe this difference. The dataset contains 100 chronological chains with 304 issues from 54 Python projects, extracted from six SWE-bench-family benchmarks.

The design separates three settings.

In **Oracle**, every task starts with previous human fixes applied. In **Seq**, the repository retains the agent's earlier patches, but the conversation restarts. In **Seq+Mem**, both the code and the conversation history continue.

At the first chain position, the results remain close. That is expected. There is no past to inherit yet.

By the third position, the difference appears. In some model and context-management combinations, the resolution rate fell by as much as 70% relative to Oracle. That is a relative drop, not 70 percentage points. The worst result did not require a sequence of fifty releases. The chains averaged just over three issues.

The more useful number concerns the origin of the failures. In sequential runs under the Baseline configuration, 48% of downstream errors were classified as **chain errors**: the agent failed the current issue because of the state produced by an earlier fix. In cases where the authors could attribute the error to one shared file, earlier omissions appeared about nine times as often as excessive edits.

That describes a familiar pattern. The agent fixes the function named in the issue but does not complete the refactor in the files that depend on it. The local test passes. Two tasks later, another change finds the refactor still incomplete.

Conversation memory barely solved the problem. Preserving the transcript brought small and inconsistent gains. Accumulated code is not merely context missing from the window. It is executable state.

The limits are clear. ChainSWE uses Python projects and tasks mined from existing benchmarks. The authors acknowledge that some tests may require details that could not be inferred from the text of an earlier issue. The result does not prove that every agent will lose 70% on every repository.

It shows something more specific: isolated-task performance does not remain stable merely because the model is unchanged.

## Passing the test can still leave an unacceptable patch

Time is not the only thing the reset hides.

[SWE-Gate](https://arxiv.org/abs/2609.04167), submitted in September 2026, adds constraints derived from real code review comments. The benchmark has 303 instances across 75 Python repositories and separates functional tests from tests for those constraints.

In experiments with four LLM backends under the same scaffold, 644 repairs passed the functional tests. Of those, 221 failed the review constraints. That is 34.3% of functionally green patches.

The number does not mean one third of all agent code will be rejected. The instances were constructed around the constraints and do not reproduce the full conversation of the original pull request. The separation is still valuable.

A suite may confirm that the error was fixed while failing to check:

- the exact exception type;
- the stable ordering of a result;
- whether a resource is closed;
- schema compatibility;
- the full scope of the fix;
- compatibility with earlier behavior.

These requirements often live in review because they do not fit only in the functional test for the issue. When a benchmark ignores them, it measures "worked" and calls it "accepted change".

Those are different states.

## A green patch leaves residue too

[SWE-STEPS](https://arxiv.org/abs/2604.03035) reaches the same problem from another direction. The work organizes 168 tasks covering 963 pull requests from six Python repositories into sequences of three to eleven PRs. Instead of discarding state, it tracks regressions and repository health over time.

In the evaluated subsets, the isolated configuration overestimated resolution rate by as much as 20 percentage points. In the Mini analysis, using the Global setting and chains longer than five PRs, the authors also compared cognitive complexity and technical debt with SonarQube. In Conan, Haystack, and Moto, agent-produced code ended with worse metrics than the human implementations.

That second result needs care. The health analysis covered subsets, a few repositories, and static metrics that do not equal maintainability as a whole. SonarQube does not know the architecture the team wants to build.

The signal still matters because it appeared even in cases of high functional performance.

Technical debt does not disappear when the author is an agent. If generation volume grows faster than the capacity to [review and understand changes](/en/quando-commits-escalam-mais-rapido-que-reviews/), that liability can accumulate faster than the fixes.

A green patch can still increase the cost of the next change.

## Human work between tasks is a hidden subsidy

There is a simple way to make an agent look better: have a person repair the repository before every new delegation.

The developer fixes the brittle test, removes the duplicate abstraction, updates the documentation, explains the convention in `AGENTS.md`, and gives the agent a coherent base. The next task starts and the score rises again.

That work usually disappears from the measurement.

We call the agent run successful and count the human intervention as normal maintenance. Without it, the next task might have failed because of the previous patch. The benchmark performs this cleanup with a reset. The team does it through review, rework, and context carried by people.

That is why I would add an inelegant metric: **reset budget**.

How many times was it necessary to:

- reverse an agent decision before continuing;
- rewrite code that already passed the tests;
- reconstruct context lost between sessions;
- fix a regression inherited by another task;
- stop the sequence and return to a human commit;
- ask a maintainer to prepare the ground?

An agent that resolves eight out of ten tasks but requires three human cleanups between them does not have the same autonomy as one that resolves seven and leaves the repository usable from beginning to end.

The denominator cannot be only closed issues. It must include how often someone restored the conditions that made the agent look autonomous.

## The unit of evaluation needs to grow

I am not arguing that we should abandon isolated benchmarks. They remain useful for comparing local capability, cost, and regressions between model versions.

I am arguing that we should stop using them alone when the intended deployment is continuous.

If I were evaluating a coding agent for real work in a repository, I would keep two tracks.

The first would be isolated. Every task starts from a known human base. It measures raw ability to solve the problem.

The second would be persistent. The agent receives a short sequence of real changes in the same worktree, with a growing regression suite and its own patches as the starting point. It measures operation.

In that second track, I would record:

1. completion rate for the whole sequence, not only the average per issue;
2. failures caused by earlier patches;
3. review constraints satisfied;
4. regressions introduced and time to detection;
5. human intervention between tasks;
6. changes in complexity and debt as signals, not verdicts.

I would also keep an Oracle run. Applying previous human changes before each step helps separate the difficulty of the issue from the damage accumulated by the agent.

This design costs more. It requires representative sequences, graders that understand regression, and review of failures. The alternative is cheap only in the spreadsheet. The cost returns in the repository.

## The benchmark started measuring continuity

In 2026, new benchmarks started replacing the isolated issue with sequences that preserve state.

ChainSWE asks what happens when the agent inherits its own code. SWE-STEPS observes whether repository health follows the resolution rate. SWE-Gate separates a green test from a constraint accepted in review.

None of them represents company work on its own. All have limited samples, languages, and graders. They still point toward a necessary correction.

Software is not a collection of independent issues. Every change alters the cost of the next one.

Using agents continuously does not suspend that property. They need to be evaluated in the same cumulative time in which the system exists.

The final question is not "did the agent solve this ticket?"

Ask:

> If the next ticket starts from exactly the state the agent left behind, would you still call this run a success?

## Sources

- [ChainSWE: Benchmarking Coding Agents on Multi-Bug Software Maintenance](https://arxiv.org/abs/2607.02606)
- [SWE-Gate: Passing Functional Tests Is Not Enough for Software Engineering Agents](https://arxiv.org/abs/2609.04167)
- [Beyond Isolated Tasks: A Framework for Evaluating Coding Agents on Sequential Software Evolution](https://arxiv.org/abs/2604.03035)
