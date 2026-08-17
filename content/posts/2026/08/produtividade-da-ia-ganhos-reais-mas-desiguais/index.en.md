---
title: "AI Productivity Is Not One Number: Why the Gains Are Real but Uneven"
description: "Randomized experiments, field studies, and enterprise data show that AI increases software-production capacity, but does not always accelerate delivery."
date: "2026-08-17T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - software-development
    - developer-productivity
    - engineering
    - research
url: /en/produtividade-da-ia-ganhos-reais-mas-desiguais/
cover: cover.jpg
cover_alt: "Blue laptop with code open on a work desk."
cover_credit_name: "Bayu Syaits / Unsplash"
cover_credit_url: "https://unsplash.com/photos/laptop-and-phone-on-a-desk-with-coding-software-open-oYzjGQ7LCVE"
---

When someone claims that artificial intelligence makes developers 30% more productive, the next question should be: **30% of what?**

Time to complete a task? Pull requests? Commits? Deployments? User value? Team satisfaction? Each metric captures a different part of engineering work.

The evidence available through August 2026 supports a more useful conclusion than a universal multiplier: **AI increases the capacity to produce software, but the realized gain depends on the task, the repository, the developer’s experience, the tool’s interaction mode, and the system’s ability to review the output**.

The gains are real. They are also unevenly distributed.

## Productivity has several denominators

Before comparing studies, we need to separate the questions that are often mixed together:

| Measure | Question it answers |
| --- | --- |
| Task speed | How long did it take to complete the same work? |
| Throughput | How many tasks, PRs, or commits were produced? |
| Delivery flow | How long does a change take to reach users? |
| Quality and reliability | How much rework, failure, rollback, or incident appeared afterward? |
| Value | Did the software solve an important user or business problem? |
| Developer experience | Is the team more focused, satisfied, and sustainable? |

An improvement in one row does not guarantee an improvement in every other row. It is entirely possible to write code faster, open more PRs, and still wait longer for review before deployment.

## What the research actually measures

The results below appear to disagree because they measure different populations and outcomes:

| Evidence | Main result | How to interpret it |
| --- | --- | --- |
| Controlled GitHub Copilot experiment | 55.8% less time on a JavaScript HTTP-server task ([study](https://arxiv.org/abs/2302.06590)) | A strong effect on a well-defined, self-contained task. It is not a full product-cycle measure. |
| Google enterprise RCT | Approximately 21% less time on a complex enterprise-grade task with 96 engineers ([study](https://arxiv.org/abs/2410.12944)) | Positive evidence in a real environment, but based on one task and specific internal tools. |
| Three field experiments published in *Management Science* | 26.08% more completed tasks across 4,867 developers ([study](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)) | The broadest causal evidence so far. The estimate is noisy, focuses mainly on code-completion access and output volume, and was larger among less-experienced developers. |
| METR RCT | Tasks took 19% longer for 16 experienced developers completing 246 tasks in mature projects ([study](https://arxiv.org/abs/2507.09089)) | An important causal warning about brownfield work, tacit context, and validation costs. It is not a universal AI impact rate. |
| Open-source study, revised in August 2026 | 5.9% more project code contributions, but 8% more coordination time ([study](https://arxiv.org/abs/2410.02091)) | More production can come with more discussion, integration, and coordination. |
| Longitudinal study of a company with a 2x mandate | 2.09 times more PRs per active developer in April 2026, while review load roughly doubled ([study](https://arxiv.org/abs/2607.01904)) | Strong evidence that large gains are possible in a favorable organization, but the study was not randomized and covers one company. |

The key result is not choosing a winning number. It is recognizing that each number estimates a **different effect**.

## 1. AI is excellent at some tasks and mediocre at others

The largest gains appear when the problem is well specified, local, testable, and composed of patterns the model already knows. Creating a conventional endpoint, generating tests, transforming data structures, producing initial documentation, or writing repetitive code are examples where raw speed is likely to show up.

Ambiguous, architectural, or historically constrained tasks are different. They require understanding implicit contracts, old decisions, business exceptions, and consequences that are not written in one file.

That is exactly the setting in which the METR study found a slowdown. Participants worked in mature repositories they already knew well. With AI enabled, they spent less time coding but more time reviewing generated output, writing prompts, waiting, and correcting changes. The model produced text quickly, but it did not have all the tacit knowledge required to produce a merge-ready change.

A simple bottleneck example helps explain this. If coding represents 40% of a delivery cycle and AI makes that part 25% faster, the theoretical gain across the full cycle is only 10%, before rework, review, and incident costs. This is an illustration, not an observed estimate, but it shows why a large local improvement can become a small system-level improvement.

## 2. Context is a multiplier

Models can read files, but reading is not the same as understanding a system’s operational context.

A repository with current documentation, reliable tests, fast CI, modular architecture, and clear feedback gives the model an environment where errors are discovered early. A repository with fragile tests, tightly coupled services, and rules stored in the memories of a few people turns every suggestion into an investigation.

The longitudinal study of the company with the 2x mandate found that gains were concentrated in newer code and barely present in legacy code. That is consistent with the METR result: the more tacit knowledge and historical compatibility a change requires, the more expensive it is to verify whether the generated code is actually correct.

This is why AI works best as a multiplier of a healthy engineering foundation. It does not replace documentation, testing, or observability. In many cases, it makes their absence more expensive.

## 3. The bottleneck moves from generation to review

The development system has limited capacity to review, integrate, and operate changes. If AI increases generation without increasing that capacity, the queue simply appears somewhere else.

DORA described this tension at two different points in time. Its earlier GenAI report associated a 25% increase in adoption with a 1.5% decline in delivery throughput and a 7.2% decline in delivery stability. Its explanation was that fast generation encourages larger changes, which take longer to review and are more likely to destabilize the system ([DORA GenAI report](https://dora.dev/ai/gen-ai-report/report/)).

In the 2025 report, based on nearly 5,000 technology professionals, the association between AI adoption and throughput became positive, while stability remained negatively associated with adoption ([DORA 2025 report](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)). This looks less like a contradiction than a sign of adaptation: teams learned to absorb more production, but reliability still requires investment.

The most recent enterprise study reinforces the same interpretation. PR volume rose to 2.09 times the baseline, but reviewer load also roughly doubled. Automated review covered more changes, while merge and revert rates stayed stable. Generation did not eliminate review work; it reorganized it.

There is also a collective effect. The latest open-source study found more contributions and participation, but 8% more coordination time. In a community, a suggestion that saves time for the author can create additional discussion for the integrator.

## 4. Experience distributes the gain unevenly

The field experiments published in *Management Science* found higher adoption and larger gains among less-experienced developers. This suggests that coding assistants can lower entry barriers and help people produce in areas where they do not yet know every pattern.

Experience has a second effect, however. Senior developers are precisely the people most able to identify subtle bugs, architectural violations, and fragile decisions. A recent observational open-source preprint found that contributions from peripheral developers increased, while core maintainers reviewed more code and produced less original code ([maintenance-burden study](https://arxiv.org/abs/2510.10165)). That work is still a preprint and uses observational identification, so it should be treated as a signal rather than definitive causality.

The question is not only whether each developer became faster. It is also: **who absorbed the cost of the speed?**

## 5. The tool baseline is changing

We should not treat METR’s 19% slowdown as a permanent snapshot of AI programming. The study measured tools available between February and June 2025, primarily Cursor Pro and Claude 3.5/3.7 Sonnet.

In a February 2026 update, METR said newer tools probably speed developers up more. At the same time, the organization considered its new experiment inconclusive: developers who did not want to work without AI stopped participating, some participants changed the tasks they submitted, and using multiple agents made time measurement unreliable ([METR update](https://metr.org/blog/2026-02-24-uplift-update/)).

That caution matters. The current landscape mixes autocomplete, in-IDE chat, agents that edit repositories, and agents that execute tasks in parallel. Each mode changes the distribution of work and the right way to measure time.

## 6. Perceived speed is not delivered value

A METR survey of 349 technical workers in early 2026 found a median self-reported value increase between 1.4x and 2x, and a 3x self-reported speed increase. The authors explicitly warn that the sample was a convenience sample, response rates were approximately 2% among contacted participants, and the magnitude may be overstated. They also distinguish speed from value: AI can make a task possible that would not have been prioritized before, without creating twice the product value ([METR survey](https://metr.org/blog/2026-05-11-ai-usage-survey/)).

DORA found something complementary: intensive users report more flow, satisfaction, and productivity, but do not necessarily spend less time on bureaucratic work. A small 13-month longitudinal study of three agile teams observed higher performance and perceived efficiency with roughly flat activity, suggesting greater value density rather than simply more volume ([agile-team study](https://arxiv.org/abs/2602.13766)).

This changes the management question. Instead of asking, “How many lines or PRs did AI add?”, we should ask, “What important work became possible, better, or faster?”

## How to measure it in your team

A serious evaluation needs to combine generation metrics with absorption metrics:

1. **Segment by task type.** Compare tests, documentation, maintenance, new features, refactoring, and architectural changes separately.
2. **Measure the full cycle.** Track time to merge, review waiting time, rework, rollback, and time to production, not just typing time.
3. **Track quality.** Observe change failures, escaped defects, incidents, reversions, and changes that need to be reopened.
4. **Measure review capacity.** AI can improve individual output while increasing queues and maintainer workload.
5. **Include experience and context.** Compare results by seniority, repository familiarity, codebase maturity, and tool mode.
6. **Connect productivity to value.** Use feature adoption, problem-resolution time, user satisfaction, and business outcomes where appropriate.

Lines of code, PR counts, and suggestion-acceptance rates can be useful secondary signals. On their own, they are easy to inflate and difficult to connect to better software.

## The most useful conclusion

AI is not a constant multiplier applied to every developer and task. It is an **amplifier with a distribution of effects**.

The largest gains appear when work is well specified, testable, and supported by strong engineering practices. The smallest gains, and sometimes losses, appear when the main cost lies in understanding context, validating behavior, coordinating people, or maintaining legacy systems.

The future of software productivity will not be decided only by generation speed. It will be decided by the ability to specify, review, integrate, and operate the code that gets generated.

The gains are real. To turn them into real value, teams must increase verification capacity alongside generation capacity.
