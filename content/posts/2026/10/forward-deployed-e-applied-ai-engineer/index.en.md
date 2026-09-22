---
title: "What a Forward Deployed Engineer and an Applied AI Engineer do"
description: "I read five postings open in September 2026 at Palantir, OpenAI, and Anthropic. They describe the same arc, from an open question to production adoption, and they ask for two deliverables: the customer's system and what it teaches the product back home."
date: "2026-10-05T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - software-engineering
    - developer-experience
url: /en/forward-deployed-e-applied-ai-engineer/
cover: cover.jpg
cover_alt: "Five people around a wooden table, each with an open laptop."
cover_credit_name: "Marvin Meyer"
cover_credit_url: "https://unsplash.com/photos/group-of-people-using-laptop-computer-QckxruozjRg"
---

Palantir describes a Forward Deployed AI Engineer's day as a hands-on AI startup CTO's: small team, high-stakes project, delivery owned end to end with the client.

OpenAI writes, in the Applied AI Engineer posting, that success is production systems and sustained adoption, not activity or successful demonstrations.

Anthropic puts technical workshops and code review with the customer's engineering team on the responsibility list.

All three are hiring for the same stretch of work: take a model that already works and make it work inside someone else's system.

**The job is to carry a model from capability to the customer's production. The deliverable is double: the system that now runs there, and what that experience sends back to the product of whoever sold the model.**

I read five job pages in September 2026, two from Palantir, two from OpenAI, one from Anthropic. They say what each company advertises, not what happens after someone joins. Everything below comes from those texts.

## The arc starts before there is a spec

None of the postings begins with a settled requirement.

Palantir opens the [Forward Deployed Software Engineer posting](https://jobs.lever.co/palantir/5168e8fd-fec1-4fea-b7a1-81bdaea65850) with questions like "how do we predict and mitigate wildfire risks across a power grid" and "how can we analyze and adapt a global supply chain to deliver critical parts on time". The text asks the engineer to stay with the problem until it is theirs.

OpenAI lists the whole sequence under one owner in the [Forward Deployed Engineer posting](https://openai.com/careers/forward-deployed-engineer-(fde)-sf-san-francisco/): discovery, technical scoping, system design, build, and production rollout.

In [Applied AI Engineer, Enterprise](https://openai.com/careers/applied-ai-engineer-enterprise-san-francisco/), the same chain shows up with one more link named in the middle: use-case selection, architecture, prototyping, evaluation, production launch, and scale.

At [Anthropic](https://www.anthropic.com/careers/jobs/5057647008), the engineer follows a portfolio of accounts from technical discovery through deployment, translating business requirements into technical solutions alongside the sales team and the Applied AI Architects.

The pattern holds across all four. The person arrives before anyone knows what to build and leaves when the thing is running with users on it.

## What these people build

The [Forward Deployed AI Engineer posting](https://jobs.lever.co/palantir/636fc05c-d348-4a06-be51-597cb9e07488) talks about building LLM workflows at scale and implementing solutions into the real world of the partner organization. The FDSE posting is more concrete about the surroundings: custom applications, LLM workflows, and production solutions engineered for that customer's reality, plus data at a scale that breaks assumptions.

OpenAI spells out what leaves an Applied AI Engineer's hands: prototypes, evaluation harnesses, reference implementations, integrations, and production accelerators. In the FDE posting, the list includes full-stack systems and working patterns codified into tools, playbooks, or building blocks others can use.

Anthropic describes customized pilots, prototypes, and evaluation suites as the way to influence the customer's architecture decisions and product strategy.

Notice what sits next to code in every list: evaluation. It is not a closing step. At OpenAI it is in the middle of the delivery chain. At Anthropic it is the artifact that carries the architecture conversation.

## What is expected from the person in the chair

**Hands on the code.** OpenAI asks the FDE to write and review production-grade code across frontend and backend, and to contribute directly in the code when progress depends on it. For Applied AI, it requires personal contribution in code, architecture, evaluation, debugging, or production engineering, and says plainly that program or stakeholder management is not enough. Palantir asks for language proficiency in both postings. Anthropic asks for Python or TypeScript with production applications.

**Evaluation as a stated skill.** OpenAI expects systematic evaluation of AI systems using representative data, graders, production signals, and human judgment. Anthropic asks for production experience with LLMs including evaluation frameworks and transcript analysis. Palantir lists Evaluation as the first of the Machine Learning basics it requires from a Forward Deployed AI Engineer.

**Everything around the model.** OpenAI enumerates the decisions the role owns: model behavior, reliability, latency, cost, safety, security, governance, and operational readiness. For enterprise environments it adds integrations, observability, privacy, and data governance. Palantir asks its FDSE for secure development practice, including vulnerability management, access control, and privacy.

**Talking to the whole organization.** Palantir describes owning relationships from the users in the weeds to the executives making the calls. OpenAI says the team works with customer executives, product and engineering teams, security leaders, and transformation teams. Anthropic includes workshops and code reviews with customer engineers, plus conferences, speaking, blog posts, and white papers.

**Ambiguity as a working condition.** Palantir asks for agency, decisions with incomplete information, and a willingness to work past the product's current boundaries. OpenAI asks for scoping and delivery in fast-moving environments, and judgment under pressure.

**Physical proximity is still in the design.** Palantir's FDSE expects 25% to 50% travel, the Forward Deployed AI Engineer up to 25%, OpenAI's FDE up to 50%. Anthropic says occasional travel. OpenAI's Applied AI Engineer posting does not mention travel, only three office days per week.

The entry bar varies widely. FDSE asks for six months of post-college experience. Anthropic asks for four years or more. OpenAI's FDE asks for five years or more, including customer-facing work.

## The second deliverable explains the role in the industry

Four of the five postings ask for field experience to flow back home.

Palantir wants the Forward Deployed AI Engineer to contribute learnings back to AIP. OpenAI measures the FDE by eval-driven feedback that changes the product and model roadmaps, and describes the Applied AI team as turning deployment lessons into better products and reusable patterns for customers everywhere. Anthropic asks for common design patterns to become insights for Product and Engineering, and for what repeats to become internal or public material. The only posting without that loop is FDSE, the one job of the five without AI in the title.

That second deliverable is the part I find most interesting.

OpenAI's enterprise text says where the difficulty lives: existing architectures, diverse data environments, security and governance requirements, multiple stakeholder groups, and organization-wide change. None of those items is model capability.

A company selling a model needs an instrument to see that, and the instrument is a person inside the customer, writing code and evals, with an open channel to the product team. That is what these postings are buying.

The limit is worth stating. Five job pages show what a company wants to attract and how it says it will measure. They do not show how many of those hires end in adoption, or how much field learning actually moves a roadmap.

## Where this touches people outside a lab

I work in Developer Experience, not at a model lab. I have no external customer to embed with.

The function still shows up without the title. When a squad wants an agent inside a real workflow, someone has to sit with the team that owns the problem and understand the dirty data, the permissions, the SLA, and what the user does when the model is wrong. That person has to leave with evals and a pattern the next squad can copy.

I have written about [evaluating agents beyond the vibes check](/en/avaliando-agentes-de-ia-alem-do-vibes-check/) and about [how much the harness carries](/en/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/). Seeing evaluation written in as a hiring requirement, across four postings at three companies, is the clearest signal I found that this part stopped being optional.

The title on the job page is each company's call. The question a team can answer internally is a different one.

> Who on your team answers for the agent's adoption three months after go-live?

## Sources

- [Palantir, Forward Deployed Software Engineer](https://jobs.lever.co/palantir/5168e8fd-fec1-4fea-b7a1-81bdaea65850)
- [Palantir, Forward Deployed AI Engineer](https://jobs.lever.co/palantir/636fc05c-d348-4a06-be51-597cb9e07488)
- [OpenAI, Forward Deployed Engineer (FDE), San Francisco](https://openai.com/careers/forward-deployed-engineer-(fde)-sf-san-francisco/)
- [OpenAI, Applied AI Engineer, Enterprise](https://openai.com/careers/applied-ai-engineer-enterprise-san-francisco/)
- [Anthropic, Applied AI Engineer, Enterprise Tech](https://www.anthropic.com/careers/jobs/5057647008)
