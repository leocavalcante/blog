---
title: "AI Productivity Is Not One Number: Why the Gains Are Real but Uneven"
description: "AI writes code faster. The harder question is whether it became easier to deliver software that people can understand, review, and maintain."
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

The conversation about AI productivity is stuck on a number.

55.8%. 26%. 19%.

Pick the percentage that supports your argument and you already have a slide for the next meeting. The problem is that software is not a slide. The number can be correct and still tell only part of the story.

If you have read my posts about [commits scaling faster than reviews](/en/quando-commits-escalam-mais-rapido-que-reviews/) and [the next step in AI-assisted development](/en/o-proximo-salto-do-desenvolvimento-com-ia-da-assistencia-a-orquestracao/), you know I do not buy the idea that productivity simply means generating more code per hour.

AI has become very good at producing code. The harder question is whether it became easier to produce software.

My reading of the research through August 2026 is straightforward: **the gains exist, but they are not a universal multiplier. They depend on the task, the repository, the developer’s experience, the tool’s interaction mode, and the team’s review capacity**.

The gains are real. They are not evenly distributed.

## First: 30% of what?

Before comparing studies, we need to stop mixing different metrics in the same sentence:

| Metric | What it measures |
| --- | --- |
| Task speed | How long did it take to do the same work? |
| Throughput | How many tasks, PRs, or commits were produced? |
| Delivery flow | How long does a change take to reach users? |
| Quality | How much rework, rollback, bug, or incident appeared afterward? |
| Value | Did the software solve an important problem? |
| Experience | Is the team more focused and sustainable? |

One metric can improve while another gets worse. You can write code faster, open more PRs, and wait longer for review before deployment. You can feel more flow and still spend the same hours in meetings, bureaucracy, and coordination.

That is where the confusion begins.

## The numbers are not fighting each other

The results below look contradictory because they answer different questions:

| Study | Result | What I would take from it |
| --- | --- | --- |
| Controlled GitHub Copilot experiment | 55.8% less time on a JavaScript HTTP-server task ([study](https://arxiv.org/abs/2302.06590)) | A small, well-defined, self-contained task can become much faster. This is not the complete product cycle. |
| Google enterprise RCT | About 21% less time on a complex task, with 96 engineers ([study](https://arxiv.org/abs/2410.12944)) | Gains exist in a real environment, but one task and internal tools do not represent the whole market. |
| Three field experiments published in *Management Science* | 26.08% more completed tasks across 4,867 developers ([study](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)) | The broadest causal evidence so far. It measures development output, and the effect was larger among less-experienced developers. |
| METR RCT | Tasks took 19% longer for 16 experienced developers completing 246 tasks in mature projects ([study](https://arxiv.org/abs/2507.09089)) | Brownfield work, tacit context, and validation can erase the gain or turn it into a slowdown. |
| Open-source study, revised in August 2026 | 5.9% more code contributions, but 8% more coordination time ([study](https://arxiv.org/abs/2410.02091)) | More production does not mean free coordination. |
| Longitudinal study of a company with a 2x mandate | 2.09 times more PRs per active developer, while review load roughly doubled ([study](https://arxiv.org/abs/2607.01904)) | Large gains are possible, but this is a non-randomized case that was very favorable to AI. |

We cannot pick one number and call it “AI productivity.” Each study is estimating something different.

## 1. The magic appears in well-defined tasks

The largest gains appear when the problem is local, testable, and based on familiar patterns. Creating a conventional endpoint, generating tests, transforming a data structure, writing initial documentation, or producing repetitive code are tasks where raw speed shows up easily.

The Copilot experiment used a JavaScript HTTP server. Its 55.8% result matters. It is also exactly the kind of number that becomes marketing when people forget to say what was measured.

The real world has a less convenient part. Architecture, business rules, security, performance, and legacy maintenance do not come with a clean prompt and a perfect test suite. They require understanding why that strange code exists, which customer depends on that exception, and which behavior cannot change.

That is the environment in which METR found a slowdown. With AI enabled, developers spent less time coding but more time reviewing the output, writing prompts, waiting, and correcting changes. The code appeared quickly. The understanding did not.

There is a simple bottleneck here. If coding represents 40% of a delivery cycle and AI makes that part 25% faster, the theoretical gain across the full cycle is 10%, before review, rework, and incident costs. This is an illustration, not an observed estimate, but it explains why a huge improvement in generation can become a small improvement in delivery.

## 2. Context is the multiplier nobody puts on the slide

A model can read files. That does not mean it knows why the code was written that way.

A repository with current documentation, reliable tests, fast CI, modular architecture, and clear feedback gives an agent a fair chance to find its own mistakes. A repository with fragile tests, tightly coupled services, and rules kept in the heads of three people turns every suggestion into an investigation.

The longitudinal study of the company with a 2x mandate found gains concentrated in new code and barely present in legacy code. That matches METR’s experience: the more tacit knowledge and historical compatibility a change requires, the more expensive it becomes to verify whether the generation is actually correct.

This is why I see AI as a multiplier of a healthy engineering foundation. It does not replace documentation, testing, or observability. In many cases, it makes their absence more expensive.

## 3. Generation accelerates. Review is still human.

Writing code became cheaper. Understanding code did not.

An agent can open a PR in minutes. That does not mean someone can understand the PR in minutes. Review still requires reconstructing context, comparing alternatives, identifying risk, checking tests, and deciding whether the change should exist.

As I wrote in [When Commits Scale Faster Than Reviews](/en/quando-commits-escalam-mais-rapido-que-reviews/), the expensive part of review was never reading characters. It was forming judgment.

DORA found this tension at different points in time. Its earlier GenAI report associated a 25% increase in adoption with a 1.5% decline in delivery throughput and a 7.2% decline in stability. The explanation is plausible: fast generation encourages larger changes, which take longer to review and are more likely to destabilize the system ([DORA GenAI report](https://dora.dev/ai/gen-ai-report/report/)).

In the 2025 report, based on nearly 5,000 technology professionals, the association between AI adoption and throughput became positive, while stability remained negatively associated ([DORA 2025 report](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)). Teams learned to absorb more output. Reliability still demands investment.

The latest enterprise study tells the same story another way: PRs grew 2.09 times, but reviewer load also roughly doubled. Automated review covered more changes. Review work did not disappear; it moved.

In open source, the effect appears as coordination: more contributions, more participation, and 8% more time spent discussing and integrating. A suggestion can save time for the author and create additional work for the maintainer.

## 4. The speed is not distributed evenly

The field experiments published in *Management Science* found higher adoption and larger gains among less-experienced developers. That makes sense: a coding assistant lowers the barrier to producing something a person could not yet write alone.

But there is another side. A senior developer is the person who notices the subtle bug, the architectural violation, and the abstraction that looks elegant but will cost the team six months from now.

A recent observational open-source study found more contributions from peripheral developers, while core maintainers reviewed more code and produced less original code ([maintenance-burden study](https://arxiv.org/abs/2510.10165)). The work is still a preprint and does not establish causality by itself. Even so, it points to a question that almost never appears on the productivity slide:

**Who absorbed the cost of the speed?**

If juniors generate more while seniors spend the day correcting it, the team did not simply gain productivity. It redistributed work and risk.

## 5. The tools are changing, so the baseline is changing too

I would not use METR’s 19% slowdown as a permanent picture of AI programming. The study measured tools available between February and June 2025, primarily Cursor Pro and Claude 3.5/3.7 Sonnet.

In February 2026, METR said newer tools probably speed developers up more. It also said its latest experiment was inconclusive: people who did not want to work without AI stopped participating, some chose different tasks, and using multiple agents made time measurement unreliable ([METR update](https://metr.org/blog/2026-02-24-uplift-update/)).

That caution matters. Today we mix autocomplete, in-IDE chat, agents that edit a repository, and agents that work in parallel. Each mode changes the distribution of work and the right way to measure time.

What I would not do is replace an old number with a new 2x promise without measuring the actual workflow.

## 6. Faster is not the same as more valuable

A METR survey of 349 technical workers in early 2026 found a median self-reported value increase between 1.4x and 2x, and a 3x self-reported speed increase. The authors warn that the sample was a convenience sample, response rates were approximately 2% among contacted participants, and the gains may be overstated ([METR survey](https://metr.org/blog/2026-05-11-ai-usage-survey/)).

They make a distinction I consider essential: speed and value are not the same. AI can make a task possible that would never have entered the backlog. That is useful. It does not automatically mean the product gained twice the value.

DORA found something complementary: intensive users report more flow, satisfaction, and productivity, but do not necessarily spend less time on bureaucracy. A small longitudinal study of three agile teams found higher performance and perceived efficiency with roughly flat activity, suggesting greater value density rather than simply more volume ([agile-team study](https://arxiv.org/abs/2602.13766)).

The management question changes from “How many lines did AI write?” to: **What important work became possible, better, or faster?**

## How I would measure this on a team

I would start with one simple rule: do not measure AI with a single metric.

1. **Separate task types.** Tests, documentation, maintenance, new features, refactoring, and architecture are not the same thing.
2. **Measure the full cycle.** Time to merge, review waiting time, rework, rollback, and time to production matter more than typing time.
3. **Track quality.** Change failure, escaped bugs, incidents, reverts, and reopened PRs belong in the calculation.
4. **Measure review load.** If output goes up and the review queue explodes, there is a problem, even if the commit dashboard looks great.
5. **Segment by context.** Seniority, repository familiarity, codebase maturity, and tool mode change the result.
6. **Connect productivity to value.** Feature adoption, problem-resolution time, user satisfaction, and business outcomes are better signals than lines of code.

Lines of code, PR counts, and suggestion-acceptance rates can help as secondary signals. On their own, they are easy to inflate and difficult to connect to better software.

## The conclusion I can defend

AI is not a constant multiplier applied to every developer and task. It is an **amplifier with a distribution of effects**.

For a clear, local, testable task, the gain can be huge. For a legacy system full of tacit context and difficult review, the gain can disappear. In some cases, the tool only accelerates the production of work that someone else will have to understand and fix.

The future of software productivity will not be decided only by generation speed. It will be decided by the ability to specify, review, integrate, and operate the code that gets produced.

The gains are real. The shortcut is not free.

If your team is producing more code, the next question is unavoidable: can you still understand and maintain all of it?

## References

- [The Impact of AI on Developer Productivity: Evidence from GitHub Copilot](https://arxiv.org/abs/2302.06590)
- [How much does AI impact development speed?](https://arxiv.org/abs/2410.12944)
- [The Effects of Generative AI on High-Skilled Work](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)
- [Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity](https://arxiv.org/abs/2507.09089)
- [The Impact of Generative AI on Collaborative Open-Source Software Development](https://arxiv.org/abs/2410.02091)
- [AI Writes Faster Than Humans Can Review](https://arxiv.org/abs/2607.01904)
- [Impact of Generative AI in Software Development](https://dora.dev/ai/gen-ai-report/report/)
- [State of AI-assisted Software Development 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)
- [METR productivity experiment update](https://metr.org/blog/2026-02-24-uplift-update/)
- [METR early-2026 AI usage survey](https://metr.org/blog/2026-05-11-ai-usage-survey/)
