---
title: "Dissecting the typed-decision hype: Jev, Laya, or your own classifier"
description: "The tables make Jev and Laya winners on different slices. The choice depends on where labels are defined and how much labelled data already exists."
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
url: /en/jev-laya-ou-classificador-proprio/
cover: cover.jpg
cover_alt: "Vintage wooden card catalog drawers with labels."
cover_credit_name: "Daniel Brzdęk"
cover_credit_url: "https://unsplash.com/photos/vintage-wooden-card-catalog-drawers-with-labels-kAQo6CJCPN4"
---

In September, three claims about the same problem circulated at the same time.

TypeSafe launched Jev with numbers of 193.6x faster and 444.6x cheaper than frontier models. ConvAI published Laya with Apache 2.0 weights and a table where the specialised checkpoint beats Jev's published number on `typed-decisions` by 0.766 to 0.727. The same table calls self-hosting "$0", meaning there is no per-token charge. The machine still costs money.

There is an older option too. TF-IDF with logistic regression classified short text against fixed labels before either company existed.

Those numbers measure different slices and do not choose what belongs in the pipeline.

**I choose based on where the labels live and how much labelled data exists.** If the taxonomy is stable and there are enough examples, I start with my own classifier. Jev and Laya fit when questions and options must change without retraining.

## The caveats are already on the product pages

The Jev announcement is more modest than the reaction suggests. Diogo Almeida says the model "achieves similar levels of intelligence on System One tasks compared to existing LLMs, while being two orders of magnitude faster and more efficient". The announcement claims similar quality at lower cost and latency. It does not say Jev judges better.

Under the charts, TypeSafe wrote sections called "Nuance". The 193.6x and 444.6x come from four workflows built by the company's model capabilities team. The reference answer is the average of two frontier models, which favours answers similar to theirs. Speed evals generally run from laptops on the US west coast.

TypeSafe also says the zero type-error rate "is not empirical". It follows from the decoder design, not from a sample. That guarantee protects the envelope; [it does not prove that the decision is correct](/en/jev-garante-o-formato-nao-a-decisao/).

The comparison table and the "Honest Limits" section on Laya's card need to be read together. The first lists "Laya (routed) 0.766" against "Jev 1.13.0 0.727" and closes with "$0 self-hosted". Further down, the card records base-checkpoint scores of 0.362 and 0.342 on the same benchmark, below the 0.461 from always guessing the majority class. Its own conclusion is direct: Laya is "a fast base to specialise, not a zero-shot decision engine".

The 0.766 belongs to `laya-typed-decisions`, trained on the 1,200 cases of that same benchmark's training split. The Jev number is zero-shot and, as ConvAI notes in italics, came from another publication; the company had no TypeSafe API access for this comparison.

The 0.081 ECE in another row needs context too. It is the post-calibration result for base Laya. Raw mean ECE was 0.466 and dropped after fitting one temperature per question type and option count on domain data.

The 0.766 shows that a specialist trained on the benchmark beats a zero-shot generalist on that benchmark. It does not support the sentence "Laya beats Jev".

The `typed-decisions` table points in two directions. Specialised Laya has the better argmax, 0.766 against 0.727. Jev's published number has better soft accuracy, 0.580 against 0.471, and lower ECE, 0.144 against 0.213. One picks the final answer correctly more often; the other stays closer to the teacher's probability distribution. The comparison remains indicative because the Jev numbers came from another publication.

## The label enters at request time or at training time

In a supervised classifier, the labels exist before training. A model for `billing`, `technical`, and `sales` learned those three classes, and adding `fraud` means labelling new examples, training again, and publishing another version of the artefact.

Jev and Laya take the list in the request:

```python
questions = {
    "department": {
        "type": "choice",
        "instructions": "Which team should handle this ticket?",
        "criteria": {
            "billing": "invoices, payments, refunds",
            "technical": "bugs, outages, system errors",
            "other": "everything else",
        },
    },
    "churn_risk": {
        "type": "noul",
        "instructions": "Does the customer threaten to cancel?",
    },
}
```

The same checkpoint can choose between departments in this call and between tools in the next one. The model reads each option's description as input, which gives it information a bare label does not carry. Several typed questions about the same state come back in a single pass.

In Laya, the mechanism is explicit: every option gets its own `[MASK]` token, the model scores those markers, and a softmax runs within the question. The answer space is built on the spot, with no retraining.

That mechanism has a concrete limit. Options share a fixed head budget: 192 tokens on the English checkpoint and 256 on the multilingual one. The card attributes part of the Banking77 drop to the few tokens available for each label. In that test, Jev's published number is 0.870 on 72 labels; Laya scores 0.425 on 77 at default settings. The Jev API accepts up to 255 options, although TypeSafe uses two stages for its highest-cardinality choices.

| Approach | Where labels are defined | Domain data to start | How a new class arrives |
| --- | --- | --- | --- |
| Jev | In the request | Not required | Change the request |
| Laya base | In the request | Not required | Change the request |
| Fine-tuned Laya | In the request, after domain training | Required | Change the request, within what the checkpoint learned to judge |
| Your own classifier | At training time | Required | Label, train, publish another version |

A fixed-head classifier does not accept an arbitrary taxonomy in the request. It trades that flexibility for specialisation.

## I measured all three on the same private set

I compared Jev, base Laya, and a classifier trained from scratch on a private set of 50 log lines, with six fixed categories and a binary decision to send for human review or not. Each side of the binary had 25 examples. One person labelled lines from one environment. I am not publishing their contents, but I am publishing the protocol and its limits.

The classifier used word n-grams of 1 to 2 and word-boundary character n-grams of 3 to 5 with TF-IDF, plus two class-balanced logistic regressions with `C=4.0` and a 0.5 threshold, one for the category and one for the review flag. I evaluated it leave-one-out: for each message, the pipeline learned vocabulary and weights from the other 49. Jev and Laya received descriptions of the six categories and of the binary question, with no training on these examples.

I left `laya-typed-decisions` out of this table. It was specialised on four other workflows, not these six categories; treating it as Laya tuned for this task would be misleading.

| Approach | Category | Review | Both correct |
| --- | ---: | ---: | ---: |
| Jev 1.13, zero-shot | 50/50 (100%) | 49/50 (98%) | 49/50 (98%) |
| Laya base, zero-shot | 44/50 (88%) | 45/50 (90%) | 40/50 (80%) |
| TF-IDF + logistic regression, leave-one-out | 43/50 (86%) | 23/50 (46%) | 19/50 (38%) |

Handwritten rules got both answers right on 47 of the 50 lines, but I wrote them after seeing the set. That keeps them out of the table as a blind competitor. The result still shows that code could handle a large part of the task without a model.

The bottom row was the surprise. The taxonomy was fixed, the favourable case for a classifier. It found the message's origin in 43 of 50 cases, but got 23 of 50 on the binary decision. Random guessing has an expected value of 25 on this balanced set. The errors suggest that 49 examples per fold did not cover enough language to distinguish a word in the text from the final state the message describes.

The taxonomy fit the classifier. The 49 examples still did not cover the decision.

### Synthetic data changed the result, not the test size

To test whether coverage was the problem, I generated 1,200 synthetic lines: 100 for each combination of six categories and two review outcomes. I used a deterministic grammar of event families, with fictional identifiers and without sending the real messages to another model. Synthetic lines went into training only. The 50 real ones remained the test.

The first generator reached 94% on both category and review. The overlap audit found a synthetic line nearly identical to a real one, with token Jaccard at 0.73. The number measured leakage. I rejected exact copies and any line above 0.55, regenerated the set, and ran everything again.

| Classifier training | Category on 50 real rows | Review on 50 real rows | Both correct |
| --- | ---: | ---: | ---: |
| 49 real rows per fold | 43/50 (86%) | 23/50 (46%) | 19/50 (38%) |
| 1,200 synthetic rows | 42/50 (84%) | 46/50 (92%) | 40/50 (80%) |
| 1,200 synthetic + 49 real rows per fold | 45/50 (90%) | 42/50 (84%) | 37/50 (74%) |

The synthetic lines raised binary accuracy from 46% to 92%. Training on them alone reached the same 40 fully correct decisions out of 50 as base Laya, but the information budgets are not comparable: I wrote the grammar after seeing the test. Mixing in the 49 real examples raised category accuracy to 90%, but lowered review and the joint result.

Varying only the size of the synthetic training set shows where the curve turns.

| Training rows | Review on 50 real rows |
| --- | ---: |
| 50 | 37/50 (74%) |
| 100 | 41/50 (82%) |
| 200 | 42/50 (84%) |
| 400 | 45/50 (90%) |
| 800 | 47/50 (94%) |
| 1,200 | 46/50 (92%) |

The method was never the bottleneck. The same TF-IDF and logistic regression pipeline reaches 94% once it has around 800 labelled examples. With 49, it sits at chance.

The test still has 50 lines. The 95% Wilson interval for 40 correct runs from 67% to 89%; for Jev's 49 correct, it runs from 90% to 100%. Every rate in this table carries the uncertainty of a small sample. I also designed the grammar after inspecting the real set, and that set had already informed protocol choices. The experiment shows that synthetic coverage can train a useful classifier. A new real holdout, separated by time or incident, has to measure generalisation.

Base Laya got 88% on category and 90% on review in this set, well above its 0.362 on `typed-decisions`. This task is simpler, with six short options instead of chained questions, and fits within the head's token budget. A near-chance result on one benchmark does not make the model useless on another task.

On a second set of eight separately written stress cases, Jev got both questions right in seven and base Laya in five. The classifier trained on all 50 real rows got five; the one trained on 1,200 synthetic rows got six. Eight examples do not support a ranking.

I ran no grid search and used no pretrained embeddings. The classifier rows measure a prespecified baseline, not the ceiling of supervised learning. Leave-one-out reuses the same set across 50 folds and does not replace a test set collected afterwards. The information budget differs too: the models got descriptions of the options; the regression got labelled examples or a grammar written by someone who knew the task. This is an engineering check with 50 lines, not a public benchmark.

On latency and cost, I will stick to what I measured. Jev's p50 was 0.37 s and p95 was 0.76 s, with requests originating in Brazil. The median fell inside TypeSafe's advertised 70 to 500 ms range for measurements taken on the west coast; p95 exceeded it. Third parties cited by ConvAI measured 236 to 276 ms p50. The 50 decisions consumed 27,987 input tokens and cost $0.0012, which puts a million messages of that size around $24. A hosted service, a local model, and a CPU regression measure different work.

## Jev, when there is no labelled data yet

Jev is the most direct option at the start, when there is no dataset and the questions fit into `choice`, `score`, and `noul`. The application describes the criteria, gets typed values with probabilities, and the team hosts no weights. On my set it was also the most accurate, without having seen a single example.

I would use that advantage to start in shadow mode: the model decides, the system does not act, and the human decisions become the first labelled set you will need anyway.

I would keep Jev when the option set changes often or several questions use the same state. It also avoids Laya's token limit in choices with many options. Early in a project, reaching the first result may matter more than operating a model.

What you do not control: the weights and the architecture are closed, and customer fine-tuning is not part of the published offering. What is left is questions, criteria, and thresholds. For many teams that is enough; for anyone with a self-hosting requirement, it is a blocker.

## Fine-tuning Laya, when the domain is specific and the options still change

`laya-typed-decisions` starts from the 421-million-parameter base checkpoint and uses RLCD, REINFORCE, and cross-entropy against the teacher's distributions. The card says the checkpoint trained on a 1,200-case split containing 6,000 decisions. The current notebook configures four epochs after reserving a calibration slice. After training, the options still arrive in the request. That is the technical gain over a fixed-head classifier: the model learns how to judge domain examples without freezing a list of classes.

I would pay that cost when three conditions show up together: the domain has patterns the base model does not know, questions or options vary between requests, and self-hosting or control over training are requirements. Without that combination, I would test Jev or a smaller classifier first.

The reproduction cost is unclear. The official notebook needs two T4s on Kaggle. The model card estimates "about 4 to 5 hours". Section 5 of the notebook itself says "~4 to 6 minutes total". The published file has no cell with execution output, so there is no way to tell which is right without running it. I would treat the duration as unverified.

The checkpoint remains tied to its training domain. The card says it was tuned on four synthetic workflows and should behave like the base model, "or worse", on anything else. I would not treat its published confidence as calibrated either. The per-type temperatures were fitted on a slice of the same training items, and the card recommends fitting them again on held-out domain data.

If your classes are six fixed queues, this fine-tune keeps a capability the application will never exercise.

## Your own classifier, when the taxonomy is stable and the data exists

With a stable taxonomy, every new example feeds exactly the artefact that goes to production. You can split train, validation, and test by time, source, and customer. You can measure false positives per class instead of looking at one average. And the model has orders of magnitude fewer parameters than 421 million.

My 50 examples were a sample. Synthetic training broadened event coverage, but it did not add independent evidence. New real lines, labelled and separated in time, will show whether TF-IDF is only the baseline or already solves the task.

I would start small and move up only when progress stalls: TF-IDF with logistic regression or a linear SVM, then frozen embeddings with a linear head, then SetFit or encoder fine-tuning. That order shows how much of the task depends on vocabulary, on general semantics, or on adapting the encoder. Jumping straight to step three hides which layer produced the gain.

Probability needs separate validation in all four approaches. Accuracy does not guarantee calibration. Temperature scaling, as in Guo et al., is a simple adjustment, but the temperature has to be learned on a set that did not train the model. The specialised Laya card documents that the published checkpoint did not keep that separation. The same goes for the threshold: if near-duplicate messages cross train and test, the number measures template memorisation. In logs, tickets, and alerts, splitting by time or by incident is usually more honest than shuffling rows.

## The decision fits in a table

| Situation | First choice |
| --- | --- |
| Stable classes, enough labelled examples, and a validated holdout result | Your own classifier |
| Stable classes and few examples | Jev as a baseline, with rules and a simple classifier alongside |
| Options change per request and an external API is acceptable | Jev |
| Options change per request and self-hosting is a requirement | Laya base |
| Options change, the domain is specific, and there is data to train on | Fine-tuned Laya |
| Dozens of options in the same question | Jev; on Laya, raise `head_max_len` or use a hierarchical `choice` |
| The rule can be computed without ambiguity | Deterministic code |

The table does not pick a threshold or price an error. A misclassification that only reorders a queue does not carry the same risk budget as a decision about access or money.

Before automating any of them, I would compare all four on the same frozen set, measuring precision and recall per class, calibration by confidence band, end-to-end cost, and the rate of escalation to human review. For Jev and Laya, the same `state`, the same descriptions, the same options. For the classifier, vocabulary and hyperparameters forbidden from seeing the test set. And [the eval continues after that first test](/en/avaliando-agentes-de-ia-alem-do-vibes-check/), with regressions in CI and signal from production behaviour.

> Must the labels change on every request, or only when the product changes?

## Sources

- [Introducing System One Models and Jev, TypeSafe](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [Jev guarantees the format. Not the decision](/en/jev-garante-o-formato-nao-a-decisao/)
- [Laya on Hugging Face](https://huggingface.co/convaiinnovations/laya)
- [Laya Typed-Decisions on Hugging Face](https://huggingface.co/convaiinnovations/laya-typed-decisions)
- [Fine-tuning notebook on 2x T4](https://github.com/NandhaKishorM/laya/blob/main/notebooks/laya_finetune_typed_decisions_2xT4_kaggle.ipynb)
- [`typed-decisions` dataset](https://huggingface.co/datasets/LocalLLaMA/typed-decisions)
- [Classification of text with sparse features, scikit-learn](https://scikit-learn.org/stable/auto_examples/text/plot_document_classification_20newsgroups.html)
- [Efficient Few-Shot Learning Without Prompts, Tunstall et al.](https://arxiv.org/abs/2209.11055)
- [On Calibration of Modern Neural Networks, Guo et al.](https://proceedings.mlr.press/v70/guo17a.html)
- [Laya has open weights. Operations stay with you](/en/laya-decisoes-tipadas-com-pesos-abertos/)
