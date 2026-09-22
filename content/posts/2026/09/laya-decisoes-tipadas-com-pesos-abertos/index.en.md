---
title: "Laya has open weights. You own the operations"
description: "Laya is a non-autoregressive decision model under Apache 2.0. It trades the convenience of a hosted API for control over running, evaluating, and specializing the model."
date: "2026-09-28T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - reliability
    - developer-experience
    - cost-management
url: /en/laya-decisoes-tipadas-com-pesos-abertos/
cover: cover.jpg
cover_alt: "Network cables organized in a datacenter rack."
cover_credit_name: "Taylor Vick"
cover_credit_url: "https://unsplash.com/photos/cable-network-M5tzZtFCOfs"
---

In September 2026, a few days after Jev launched, ConvAI Innovations released Laya. Both take a state and answer typed questions. Neither generates text. Only Laya ships weights and code under Apache 2.0.

**The clearest difference between Laya and Jev is delivery. Laya is open and self-hosted. Jev is accessed through a hosted API.**

If you already read [the Jev post](/en/jev-garante-o-formato-nao-a-decisao/), the contract is familiar: `state` goes in, `choice`, `score`, or `noul` come out with probabilities. What changes is who operates the model and how much work stays with the team adopting it.

## Laya is a family of checkpoints

ConvAI describes Laya as a System 1 model. TypeSafe uses System One for its own model class and presents Jev as the first one. The names do not establish a shared architecture, but both interfaces cover the same three question types.

ConvAI publishes three checkpoints on the `convaiinnovations/laya` hub:

| Checkpoint | Encoder | Parameters | Context | Main use |
| --- | --- | --- | --- | --- |
| root (English) | ModernBERT-large | 421M | 512 | English, triage, guardrails |
| `multilingual` | mmBERT-base | 322M | 1024 (encoder up to 8192) | 100+ languages declared on the card |
| `typed-decisions` | ModernBERT-large | 421M | 1024 | Typed-decision workflows |

All three live in the same repository. The SDK downloads the root or only the requested subdirectory. The Python package (`pip install laya`) loads a checkpoint, assembles state and questions, and returns typed answers in one forward pass. There is no chat endpoint. There is no free-form text in the output.

That lets you run offline, inside a VPC, or on your own hardware. It also lets you read the implementation, download the weights, and tune the model. Jev publishes an API, pricing, limit documentation, and evals. Its architecture and weights are not public.

## The model scores options instead of generating JSON

On the English checkpoint, ConvAI uses a bidirectional encoder (ModernBERT-large, 395M parameters in the backbone) and a decision head trained from scratch. Each option in a `choice` question gets a `[MASK]` marker. After the encoder layers, the head turns that marker's vector into a logit. A softmax per question produces the distribution across the options you defined in the call.

`score` questions use the same mechanism over ordinal rubric levels. `noul` returns the probability of a binary statement.

Every question in a call runs in the same forward pass. Total latency grows with the number of questions, but cost per question falls when they are grouped. In ConvAI's published benchmark, the multilingual checkpoint went from 32.8 ms with one question to 72.3 ms with ten on a T4.

Laya training uses rewards based on strictly proper scoring rules to align reported confidence with the observed frequency of correct answers. ConvAI calls the recipe RLCD (Reinforcement Learning for Calibrated Decisions), the same name TypeSafe uses. That does not establish that both models were trained the same way: TypeSafe has not published Jev's complete recipe.

### The English checkpoint trusts scripts it cannot read

On the MASSIVE benchmark, Khmer reached 0.000 accuracy with 0.952 mean confidence on the English checkpoint, according to numbers ConvAI published. If you use confidence to automate, you need to route before inference.

The `Router` inspects text, detects script and language signals without loading another model, and picks English, multilingual, or an explicit override. With `preload=True`, checkpoints stay resident and language flips do not pay a reload on every request. The cost is keeping more than one model in memory.

## Minimal example

```python
import laya

agent = laya.load("convaiinnovations/laya")

state = {
    "subject": "Duplicate charge on invoice #4411",
    "body": "We were billed twice for March. Refund the duplicate or we cancel.",
}

questions = {
    "department": {
        "type": "choice",
        "instructions": "Which department should handle this request?",
        "criteria": {
            "billing": "invoices, payments, refunds",
            "technical": "bugs, outages",
            "sales": "pricing, contracts",
        },
    },
    "churn_risk": {
        "type": "noul",
        "instructions": "Does the sender threaten to cancel?",
    },
}

result = agent.predict(state, questions)
print(result["answers"]["department"]["choice"])
print(result["answers"]["churn_risk"]["noul"])
```

The schema resembles what you would send to a Jev integration. The difference is runtime: here you download about 800 MB for the English checkpoint, provision CPU or GPU, and keep the process running.

## Deployment control justifies the extra work

I would consider Laya when control over deployment and training matters as much as integration convenience.

Self-hosting or air-gap is the clearest case. The weights use Apache 2.0 and inference does not depend on an external API. For internal triage or routing sensitive data, that can be a requirement.

Multilingual flows need explicit routing. ConvAI publishes results for 51 languages and offers a dedicated checkpoint. In that sweep, 45 of 51 cleared the card's threshold of three times random. I did not find an equivalent multilingual benchmark for Jev.

Fine-tuning on your own domain is where open weights change the work most. On the typed-decisions benchmark (2,000 decisions across four workflows), the specialized `typed-decisions` checkpoint reports 0.766 accuracy. The English base checkpoint scores 0.362, below the 0.461 baseline from always choosing the most common class. Multilingual is also below that baseline, although two sections of the model card publish different values for it. ConvAI publishes a fine-tuning notebook for 2×T4 on Kaggle. The gap between these numbers is a warning to train and measure on the real flow.

At high volume, the cost model also changes. Jev charges US$ 0.042 per million input tokens, according to TypeSafe. Laya trades per-request billing for hardware, power, and operations. Which one costs less depends on utilization and available infrastructure.

Open weights and code let the team inspect the architecture, reproduce evaluations, and keep its own checkpoints.

The same flows as Jev still apply: support queues, RAG passage relevance, and risk scoring with closed options. The difference is the path to production: you will probably train, calibrate temperature on your hold-out, and measure again.

## The model card shows where Laya falls short

Laya does not write email, code, or a plan. Counting, date arithmetic, and exact rules still belong in code.

I would not treat the model as the only barrier against adversarial content either. ConvAI publishes jailbreak-detection results on ToxicChat. That measures Laya as a detector, not its resistance to instructions injected into its own `state`, which the benchmark does not evaluate. Guardrails, permissions, and validation stay in software.

The 0.766 result belongs to the specialist trained on the benchmark's training split. Base checkpoints do not reach the majority-class baseline in that evaluation.

On Banking77, with 77 labels, Laya reports 0.425 on the card. The published Jev 1.13.0 comparison uses 72 labels and reports 0.870. This is not a controlled head-to-head result, but it exposes Laya's `head_max_len` budget limit. For large catalogs, ConvAI itself recommends embedding shortlists, budget increases, or coarse-to-fine hierarchy. Jev accepts up to 255 options, although TypeSafe also describes a two-stage process for larger sets.

Calibration also requires local work. On typed-decisions, the specialist reports raw ECE of 0.213. ConvAI recommends fitting temperature per question type on separate data. A distribution should guide automation only after the team compares confidence and accuracy in its own domain.

Latency depends on hardware. The 32.8 to 39.5 ms highlighted on the card was measured on a Tesla T4. The same card reports 193 to 464 ms on CPU with preload, without identifying one reference processor for the whole range. The useful number is the one measured on the application's hardware and batch size.

Hosting also requires downloading weights, reserving memory, managing PyTorch versions, and running an inference queue. Jev delivers that part as a service.

## This is not a controlled head-to-head comparison

Both models answer typed questions over the same `state`. A useful comparison separates product, out-of-the-box capability, and operating cost.

| Dimension | Jev (TypeSafe) | Laya (ConvAI) |
| --- | --- | --- |
| Access | Hosted API, closed weights | Apache 2.0 weights + Python SDK |
| Fine-tuning by the customer | No public fine-tuning | Fine-tuning notebook and adjustable checkpoints |
| Typed-decisions | 0.727 third-party figure cited by ConvAI | 0.766 on specialist; 0.362 on English base checkpoint |
| Options per `choice` | Up to 255 documented | Card warns of degradation above 20 under defaults |
| Soft accuracy (typed-decisions) | 0.580 third-party figure cited by ConvAI | 0.471 on the specialist card |
| Banking77 | 0.870 third-party figure cited by ConvAI (72 labels) | 0.425 on the card (77 labels, default) |
| Reported latency (different measurements) | 70 to 500 ms, hosted service | 32.8 to 39.5 ms on T4; 193 to 464 ms on CPU with preload |
| Multilingual | No equivalent public benchmark | Router + dedicated checkpoint |
| Marginal cost | US$ 0.042 / MTok input | Self-hosted compute |
| Integrations | TypeSafe SDK, Vercel AI Gateway | Hugging Face, Python package, fine-tuning notebook |

The table has two limitations.

First, ConvAI states that Jev numbers come from third-party publications and were not measured in the same harness. Sample count, prompts, and, on Banking77, label count differ. Latency also mixes measurements: Jev's range is end-to-end time for a hosted service, reported by TypeSafe; Laya's is local inference. Laya's model card also cites third-party Jev measurements of 236 to 276 ms p50. The table describes published results, not a controlled ranking.

Second, argmax and distribution measure different things. Laya's specialist reports 0.766 hard accuracy on typed-decisions, against the third-party Jev figure of 0.727 cited by ConvAI. For soft accuracy, the values are 0.471 for Laya and 0.580 in the cited Jev figure. The first measures the winning option. The second measures proximity to the distribution of the model used as reference.

## Code still owns the action

The model interprets text inside closed options. Code filters state, calculates dates, enforces allowlists, sets confidence thresholds, and executes side effects.

Before automating, I would measure accuracy by confidence band and separate false positives from false negatives on the real flow's hold-out. Then I would fit temperature per question type, as the card recommends.

If the catalog goes past twenty options, I would not force a single `choice`. Embedding shortlists, coarse-to-fine questions, or domain splits usually cost less than pushing 77 labels into a tight head budget.

## The choice is operational

Open weights give you control. They also move hosting, calibration, continuous evaluation, and domain tuning onto the team. Jev concentrates those operations in a service but does not let you inspect or host the model.

Both reduce format errors because they answer only within declared options. Neither guarantees that the chosen option is correct. That distinction already applied to [Jev](/en/jev-garante-o-formato-nao-a-decisao/) and does not change with open weights.

I would choose Laya when hosting and specializing the model are part of the requirement. I would choose Jev when a hosted API and support for large catalogs matter more than access to weights.

> How much control over the model does this flow need, and who will operate what comes with that control?

## Sources

- [convaiinnovations/laya on Hugging Face](https://huggingface.co/convaiinnovations/laya)
- [Laya on PyPI](https://pypi.org/project/laya/)
- [Laya: ConvAI site](https://laya.convaiinnovations.com/)
- [Decoding Jev (Navin Pai)](https://navinpai.github.io/decoding-jev/)
- [Introducing System One Models and Jev (TypeSafe)](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [TypeSafe: Choice](https://docs.typesafe.ai/primitives/choice)
- [Jev on Vercel AI Gateway](https://vercel.com/ai-gateway/models/jev)
- [Jev guarantees the shape, not the decision (this blog)](/en/jev-garante-o-formato-nao-a-decisao/)
