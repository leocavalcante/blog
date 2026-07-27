---
title: "Ontologies for AI agents: the missing contract between model, memory, and tools"
description: "LLMs can converse, but they do not share a stable domain model. Ontologies, knowledge graphs, and semantic validation can give agents a common vocabulary, safer actions, and verifiable memory."
date: "2026-08-03T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - knowledge-graph
    - software-engineering
url: /en/ontologias-para-agentes-de-ia-o-contrato-que-falta-entre-modelo-memoria-e-ferramentas/
cover: cover.jpg
cover_alt: "Person writing in a notebook beside a laptop, representing the organization of knowledge and relationships."
cover_credit_name: "Scott Graham"
cover_credit_url: "https://unsplash.com/photos/person-holding-pencil-near-laptop-computer-5fNmWej4tAA"
---

An AI agent gets a request such as: “renew the customer contract, but do not exceed the approved budget.” A human sees the hidden knowledge immediately: who the customer is, which document counts as the contract, which budget is current, what renewal means, who can approve an exception, and which system may execute each step.

For an LLM, nearly all of that arrives as text. It may get it right often. It may also call the wrong tool, confuse two similar identifiers, treat a suggestion as an approval, or produce a plausible answer that cannot safely be executed.

That is where an ontology becomes useful again. Not as an academic project to classify the whole world, but as **the minimum semantic contract for a domain**: the kinds of things that exist, how they relate, which states matter, and which combinations are invalid.

When agents share that contract, the model is no longer the only source of coherence. The LLM still interprets language, plans, and handles ambiguity; the ontology supports identity, relationships, rules, and verification.

## What an ontology adds to an agent

An ontology is a formal vocabulary for a domain and the relationships between its terms. The W3C definition is particularly useful: it describes ontologies as formalized vocabularies of terms, usually for a specific domain and a community, with definitions expressed through the relationships between those terms. [OWL 2](https://www.w3.org/TR/owl-overview/) provides classes, properties, individuals, and data values to represent them.

That differs from four things that are often conflated:

- **Prompt:** a temporary instruction to a model. It can say that an invoice needs approval, but it does not make that rule queryable or verifiable outside the conversation.
- **API schema:** a shape contract. It says that a field is a `string` or an operation takes certain parameters; it usually does not say that a `Renewal` is linked to an active `Contract` and depends on an `Approval`.
- **Vector store:** an excellent way to retrieve similar text. By itself, it is not a source of explicit identity, typing, and relationships.
- **Knowledge graph:** the concrete facts: “this contract belongs to this account,” “this budget expires on this date.” The ontology is the semantics that makes those facts comparable and interpretable.

In practice, an agent needs the last two. The graph stores instances and evidence; the ontology defines how they can be understood. RDF models facts as subject–predicate–object triples. OWL adds a layer for classes and relationships with formal meaning. A reasoner can then derive simple consequences, such as recognizing that an `EnterpriseRenewal` is also a `Renewal` because the first is a subtype of the second.

The benefit is not “making the model smarter.” It is moving some knowledge out of free text when that knowledge must remain stable across sessions, tools, and agents.

## The test: a question that needs the same answer tomorrow

A useful way to decide whether something belongs in an ontology is to ask: **if another agent received the same question tomorrow, would it need to reach the same operational interpretation?**

“What tone should I use in this email?” probably does not. That belongs in the prompt, user preferences, and retrieved context.

“Can this request draw from cost center X’s budget?” probably does. It has identifiable entities, durable relationships, states, and an action with an external effect.

For a support and operations agent, a first slice can stay small:

| Concept | Important relationships | Example rule |
| --- | --- | --- |
| `Customer` | owns `Contract`; belongs to `Account` | an account can have many customers |
| `Contract` | has `Budget`; has `ContractStatus` | only an `active` contract can be renewed |
| `Renewal` | renews `Contract`; requires `Approval` | it cannot execute without a valid approval |
| `AgentAction` | uses `Tool`; produces `Evidence` | a write action requires an audit trail |

This vocabulary is more useful than a giant taxonomy. It gives stable names to what tools receive and return, what agents store as memory, and what rules must be tested.

## The architecture that works: LLM for language, ontology for commitment

The common mistake is trying to replace the LLM with a symbolic system, or pretending an LLM will follow critical rules simply because they appear in a system prompt. A more robust design is hybrid:

```text
natural-language request
          |
          v
LLM: interprets, asks what is missing, and proposes a plan
          |
          v
entity resolver + knowledge graph
          |
          v
ontology + rules: types, relationships, and applicable policies
          |
          v
validator: allows, blocks, or requests human review
          |
          v
narrow tool executes the action and records evidence
```

The LLM is at the beginning because human language is vague and contextual. It can turn “renew Acme’s contract” into a structured proposal, but it should not invent the contract ID or silently decide which “Acme” is the right one.

The entity resolver looks for candidates in the graph and returns identifiers, confidence, and evidence. If there are two accounts with the same name, the agent asks. A disambiguation question is a better product outcome than fluent, incorrect automation.

At the end, the tool receives an intent that is already typed and validated. Instead of exposing `execute_anything(payload)`, it may expose `create_renewal(contract_id, proposal_id, approval_id)`. Narrow tools reduce the surface where the model has to improvise.

## OWL is not your production validator

OWL is valuable for modeling vocabulary and inferring relationships, but its view of the world is not the same as a business transaction. In particular, open-world semantics do not let you conclude that something is false merely because the graph does not mention it. The absence of an approval in the graph is not automatically formal proof that no approval exists.

For operational guardrails, use explicit validation. [SHACL 1.2](https://www.w3.org/TR/shacl12-core/) describes shapes that define the expected structure of RDF graphs and can support validation, inference, integration, and code generation. That creates a useful separation:

- ontology: “what it means to be a Renewal and which relationships exist”;
- shapes: “to execute a Renewal, I need exactly one contract, an approval, and valid evidence”;
- application policy: “who may approve, within which limit, and in which system”.

A small Turtle example can declare the action shape:

```turtle
@prefix ex: <https://company.example/agent#> .
@prefix sh: <http://www.w3.org/ns/shacl#> .

ex:RenewalReadyForExecution
  a sh:NodeShape ;
  sh:targetClass ex:Renewal ;
  sh:property [
    sh:path ex:renewsContract ;
    sh:class ex:ActiveContract ;
    sh:minCount 1 ; sh:maxCount 1
  ] ;
  sh:property [
    sh:path ex:hasApproval ;
    sh:class ex:ValidApproval ;
    sh:minCount 1 ; sh:maxCount 1
  ] .
```

That validation does not decide whether the price is good. It prevents the execution layer from treating an incomplete renewal as ready. Its result should return to the agent as structured data, with messages it can use to request the missing item or route the case.

## Start from friction points, not nouns

Ontology building is not making a pretty inventory of entities. The safest path starts where an agent actually fails, or where getting it wrong is expensive:

1. Choose one specific decision or external action, for example, approving an expense, provisioning access, or changing a subscription.
2. Collect real examples, including exceptions. Which names were ambiguous? Which approval was missing? Which state made the action invalid?
3. Model only the classes, properties, and states that explain those decisions.
4. Define canonical identifiers and mappings to source systems. “Customer” without an identity strategy is still only a label.
5. Write shapes and policies before connecting the write action.
6. Run positive, negative, and ambiguity cases. Measure not only success rate, but also correct blocks and useful clarification questions.

Step six is where many projects stop too early. An agent that executes one valid action proves little. Evaluation must also include missing facts, same-name entities, conflicting relationships, stale data, and attempts to get a tool to accept an object outside the contract.

## Agent memory should not be only a text diary

Textual memory is flexible and essential for qualitative reasoning: meeting context, an uncertain decision, a user’s explanation. But when memory contains operational facts, it needs provenance.

Rather than storing only “the customer accepted the renewal,” the agent can retain something like:

```text
Renewal 123 --hasApproval--> Approval 456
Approval 456 --extractedFrom--> Document 789
Document 789 --publishedAt--> 2026-07-30
```

That makes “why did you do this?” answerable with a verifiable chain, rather than a likely reconstruction of reasoning. It also lets a system invalidate facts derived from a revoked source without deleting all agent memory.

The point is governance, not only retrieval. Each fact that affects an action should carry, where possible, source, observation time, scope, and confidence. A fact extracted by an LLM from a PDF is different from state read directly from a financial API.

## When not to use an ontology

Do not turn every assistant into a semantic-web project.

Ontologies are a product cost: someone has to decide terms, version changes, map sources, document exceptions, and preserve compatibility. For open-ended work, such as summarizing a conversation, exploring ideas, drafting copy, or answering over unstructured documents, RAG and good prompts are usually enough.

The investment starts to pay off when at least one of these signals appears:

- more than one agent, team, or tool needs the same concepts;
- actions involve authorization, money, access, security, or compliance;
- the correct entity matters more than the most similar sentence;
- a decision must be explained, reproduced, or audited;
- business rules keep recurring in prompts, integration code, and spreadsheets.

Even then, start small. An ontology that covers one critical workflow and is actually enforced is better than a “universal” graph no one queries.

## The goal is to make uncertainty visible

AI agents do not need an encyclopedia of the world to be useful. They need to know precisely enough **what they are talking about, where each fact came from, and when to stop acting**.

That is the most concrete contribution of an ontology. It replaces some implicit trust in generated text with an explicit contract among models, memory, tools, and people. The LLM remains the adaptable interface; the graph provides state; rules provide boundaries; and auditability turns automation into something that can be operated.

In systems that only suggest, this may be overkill. In systems that decide, write, and move resources, it is reliability infrastructure.
