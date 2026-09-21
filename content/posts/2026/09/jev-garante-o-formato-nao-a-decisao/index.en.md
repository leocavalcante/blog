---
title: "Jev guarantees the shape, not the decision"
description: "Jev trades text generation for typed decisions with probabilities. The idea works when the answer space is closed, the question is narrow, and code stays in control."
date: "2026-09-21T13:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - reliability
    - developer-experience
    - cost-management
url: /en/jev-garante-o-formato-nao-a-decisao/
cover: cover.jpg
cover_alt: "Old railway signal box beside the tracks."
cover_credit_name: "Joseph Malone"
cover_credit_url: "https://unsplash.com/photos/old-railway-signal-box-beside-tracks-H3nVhaPXCc0"
---

Most AI APIs return text. The software receives the answer, tries to extract JSON, validates the fields, and decides whether it can trust what remains.

Jev starts with a different contract. Code defines the possible answers before the call. The model receives state, evaluates questions, and returns choices, scores, or probabilities inside that shape.

It will not write the email to the customer. It can decide which queue should receive the request. It will not calculate whether an invoice became overdue 30 days ago. It can assess whether the message conveys urgency.

**Jev fits narrow, repeated decision points with a closed output space. Outside that shape, deterministic code, a generative model, or a person remains the better choice.**

That boundary is more useful than any speed claim.

## Jev is a decision model

TypeSafe launched Jev in September 2026 as its first System One Model. The name comes from Daniel Kahneman's distinction between fast judgment and deliberate reasoning.

The product carries that distinction into the API. Instead of asking for a text response, the application sends two elements:

- `state`, with the content or application state to evaluate;
- `questions`, with the allowed decisions and criteria for each one.

The model evaluates every question in parallel. Each answer returns under the same identifier the application defined.

```json
{
  "model": "jev-latest",
  "state": {
    "message": "My payouts have been failing for three days."
  },
  "questions": {
    "department": {
      "type": "choice",
      "instructions": "Which team should handle `message`?",
      "criteria": {
        "billing": "Payments, invoices, or refunds",
        "technical": "Bugs, outages, or integrations",
        "sales": "Pricing, upgrades, or new accounts"
      }
    },
    "urgent": {
      "type": "noul",
      "instructions": "Does `message` require urgent attention?"
    }
  }
}
```

In this example, `department` can only receive one of the three options. `urgent` returns as a number from 0 to 1. There is no field where the model can draft a justification, invent a fourth department, or return a paragraph instead of the answer.

TypeSafe's direct API uses `POST /v1/systemone`. Jev is also available through OpenRouter's Decisions API and Vercel AI Gateway's experimental `evaluate`. It is not an OpenAI-compatible chat endpoint. The request shape is part of the product.

## The three types cover different problems

Jev exposes three primitives.

`Choice` selects one option from a set the application defines, with a limit of 255 alternatives. The response includes the selected option, the probability distribution across all options, and a confidence value.

`Score` places the state on an ordered rubric of up to ten levels. A team might describe the levels as "no risk", "requires review", and "block". The answer includes the distribution across levels and a weighted score.

`Noul` evaluates a binary statement and returns the probability of "yes". An output of `0.82` is not a ready-made boolean. Code still decides whether `0.82` is enough to act, ask for confirmation, or send the case to review.

These types look simple because TypeSafe designed them for simple decisions. Trying to rebuild text generation with hundreds of `Choice` questions turns Jev into the wrong model for the job.

## Type-safe describes the envelope, not the truth

TypeSafe says Jev cannot make type errors. That guarantee is testable: a `Choice` answer stays within the declared options, and the structure follows the schema.

This property matters. A value outside an enum or broken JSON can crash an integration, trigger a retry, or travel through several dependencies before it fails.

But the schema only limits how the error can arrive.

Jev can still choose `billing` when the correct destination was `technical`. It can assign a low probability to an urgent case. It can return a perfectly valid answer to a poorly written question.

So I would read the phrase "cannot hallucinate" narrowly. The model does not invent an output outside the allowed space. That does not mean the selected output matches reality.

The problem is not the shape. It is the decision inside it.

## The best case has four properties

I would use Jev when the problem meets four conditions.

First, the answer fits a known set. Support queues, document categories, risk levels, and application handlers have options that code can enumerate.

Second, the decision requires semantic judgment. If a regular expression or comparison solves the case exactly, a model adds nothing. The benefit appears when two messages with different words express the same intent, or when a handwritten rule grows into a brittle collection of exceptions.

Third, the decision happens often enough for cost and latency to matter. TypeSafe publishes a price of $0.042 per million input tokens and does not charge for output tokens. It also reports responses between 70 and 500 milliseconds on its infrastructure. Those are company figures, not an independent measurement, but they explain the intended shape: decisions inside an application flow.

Fourth, uncertainty has a safe destination. The system can ask for confirmation, call another component, or send the case to a person.

Some concrete fits:

| Decision | Type | What code does next |
| --- | --- | --- |
| Select the support queue | `Choice` | Route or request manual triage |
| Assess the relevance of a retrieved passage | `Score` | Keep, drop, or flag for review |
| Detect whether a message asks for a refund | `Noul` | Apply a product-defined threshold |
| Select a low-risk tool | `Choice` | Run only an allowed tool |
| Evaluate another model's output | `Noul` or `Score` | Allow, block, or escalate |

Jev decides among options. Code remains responsible for the effect.

## Confidence only helps when it changes the flow

`Choice` and `Score` answers include a probability distribution. The `confidence` field summarizes how concentrated that distribution is. `Noul` already returns its probability and has no separate confidence field.

Reading only the winning option throws away half of the contract.

A classification may produce `billing: 0.42`, `technical: 0.39`, and `sales: 0.19`. `billing` won, but the result does not support the same automation as a `0.96`, `0.03`, `0.01` distribution.

I would separate at least three behaviors in code:

```python
if answer.confidence < review_floor:
    send_to_human(case)
elif answer.choice == "technical":
    route_to_technical(case)
else:
    route_to_selected_queue(case)
```

The model documentation does not provide the right value for `review_floor`. It must come from labelled examples in the actual workflow and change with the cost of an error. Showing the wrong screen is recoverable. Approving a transfer is not.

Reported confidence also does not replace measured calibration. Before automating, I would compare confidence bands with the actual accuracy on representative data. Then I would monitor that relationship in production to detect distribution shifts.

## What should remain in code

TypeSafe documents a long list of `jev-1.13` limitations. It helps separate judgment from computation.

Counting, arithmetic, and date comparison stay in code. Jev reads dates as text, not as ordered quantities. If a rule says "more than 30 days", the application calculates the difference.

Invariants also stay in code. Two separate questions do not have to satisfy identities such as `P(A) + P(not A) = 1`. If the system needs that relationship, it should ask one question or enforce the rule afterwards.

Large state needs filtering first. Irrelevant detail reduces accuracy and makes a wrong decision harder to explain. Retrieval, parsing, and field selection happen before the call.

Mandatory policy does not become a prompt. Authorization limits, available balance, allowlists, and regulatory rules remain deterministic conditions.

This division leaves Jev with the part that requires interpretation and leaves software with what it can prove.

## Where Jev does not fit

Jev is not a generation model. If the expected output is an email, code, a summary, a plan, or an explanation, the application needs another tool.

It is also a poor fit for multi-step reasoning. The documentation acknowledges lower quality with indirection, complex negation, and questions about properties of properties. The safer path reduces each decision to one direct question and combines the results in code.

I would not use `jev-1.13` as the only barrier against adversarial content. TypeSafe warns that state is not treated as hostile by default and that an injected instruction inside the content can move the answer. Jev can provide one signal in a guardrail system, but it does not replace isolation, validation, and explicit rules.

I would also keep the final decision away from the model in credit, healthcare, employment, security, or any irreversible operation. A probability can order a queue or point cases toward review. It does not provide evidence, a causal explanation, or accountability for the result.

Finally, Jev does not repair a poor taxonomy. If the options overlap, leave gaps, or change every week, typed output only makes the ambiguity more organized.

## The integration needs an escape route

Before adopting Jev, I would answer five questions:

1. Is the answer set genuinely closed?
2. Which part requires judgment, and which part can code calculate?
3. What happens when confidence is low?
4. Which error could execute an irreversible action?
5. Is there a labelled set for tuning thresholds and detecting regressions?

If the third question has no answer, the system is not ready for automation. If the fourth points to money, access, or safety, high confidence is not enough. The flow needs confirmation or review.

Jev offers an unusual interface for AI: state goes in, typed decisions come out. That reduces the failure space and makes probabilities an explicit part of the code.

It does not turn judgment into certainty.

> If the model selects a valid but wrong option, which part of the system prevents that answer from becoming an action?

## Sources

- [Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [TypeSafe API reference](https://docs.typesafe.ai/api)
- [TypeSafe: Confidence](https://docs.typesafe.ai/confidence)
- [TypeSafe: State](https://docs.typesafe.ai/concepts/state)
- [Jev 1.13 jaggedness](https://docs.typesafe.ai/model-jaggedness/jev-1.13)
- [TypeSafe: Jev 1.13 on OpenRouter](https://openrouter.ai/typesafe/jev-1.13)
- [TypeSafe AI's Jev now available on AI Gateway](https://vercel.com/changelog/typesafe-ai-jev-now-available-on-ai-gateway)
