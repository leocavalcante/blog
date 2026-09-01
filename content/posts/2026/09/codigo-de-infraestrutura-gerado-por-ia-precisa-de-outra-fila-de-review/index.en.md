---
title: "AI-generated infrastructure code needs a different review queue"
description: "Dockerfiles, pipelines, and Terraform are not just another diff. When AI generates code with access to the production path, review must follow the risk of the file."
date: "2026-09-01T11:56:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - security
    - devops
    - infrastructure-as-code
    - code-review
url: /en/codigo-de-infraestrutura-gerado-por-ia-precisa-de-outra-fila-de-review/
cover: cover.jpg
cover_alt: "Cargo ship, containers, and cranes operating at a port."
cover_credit_name: "Haris Illahi"
cover_credit_url: "https://unsplash.com/photos/container-ship-loading-with-cranes-and-forklift-at-port-Dzh-udFZXrA"
---

An agent creates an endpoint and gets validation wrong. The bug may expose one route.

The same agent changes a Dockerfile, a GitHub Action, or a Terraform module. Now it may change the image running in production, hand a secret to untrusted code, or open a port to the internet.

Both results arrive as text in a pull request. The risk does not arrive at the same size.

I have already written that [commits are scaling faster than reviews](/en/quando-commits-escalam-mais-rapido-que-reviews/) and that green CI does not replace understanding. The problem gets more serious when we treat AI-generated infrastructure as if it were just another directory in the repository. It is not. These files control the environment that builds, tests, publishes, and runs the rest of the code.

My conclusion is simple: **AI-generated infrastructure code needs a different review queue**.

Not because every Dockerfile written by a model is wrong. Nor because hand-written infrastructure is safe. The difference is the size of the side effect. When a file decides permissions, networking, credentials, or deployment, its review path needs to match that power.

## The Dockerfile number is bad, but it needs to be read correctly

IOActive's 2026 report, [*The Security Gap in AI-Generated Code*](https://www.ioactive.com/wp-content/uploads/2026/05/IOA-The-Security-Gap-in-AI-Generated-Code.pdf), evaluated 27 code-generation models and applications. The study used 730 prompts, 27 languages, 216 vulnerability categories, and 72 automated detectors.

In its language analysis, 396 out of 405 generated Dockerfiles triggered at least one security finding. That is 97.8%. Terraform reached 71.8%, with 310 out of 432 samples flagged. CI/CD pipelines were vulnerable in 63.9% of the category's 675 tests, according to the report.

That is a strong result. It is also easy to turn it into a claim larger than the research supports.

The study did not observe 405 real Dockerfiles in production. It generated samples from controlled prompts and evaluated them with static analysis. A detector finding does not automatically equal a confirmed exploit. The baseline prompts also omitted security language on purpose, because the researchers wanted to measure the models' default behavior.

So "97.8% of Dockerfiles made by AI are exploitable" would be a bad reading. The useful reading is different: **in that benchmark, almost no default Dockerfile generation satisfied the controls expected by the detectors**.

That is enough to reject the idea that generated infrastructure can enter the normal flow merely because it looks short, familiar, and functional.

## Infrastructure is code with a larger lever

A Dockerfile often has few lines. A GitHub Action may fit on one screen. A Terraform plan looks declarative and orderly.

That appearance is misleading.

One `FROM` line chooses the base of the supply chain. A missing `USER` decides whether the process runs as root. A broad `COPY` may carry keys, configuration files, or build-environment debris into the final image. An action referenced by a mutable tag can change without a change in your repository.

The wrong combination is even worse in a pipeline. A `pull_request_target` event may run with a write token and access to secrets. If the workflow checks out untrusted code and then runs a script from it, a pull request becomes a path to compromising the repository. The [GitHub Actions security documentation](https://docs.github.com/en/actions/reference/security/secure-use) treats this case as a repository takeover risk.

Terraform is not merely a neat description of desired state either. A `0.0.0.0/0` ingress rule, a public bucket, a broad role, or an inadequately protected database may pass syntax validation while remaining bad security decisions.

That is why `terraform validate` does not solve the problem. The command checks syntax, arguments, names, and types. It does not prove that the plan should be applied.

Application code usually implements behavior inside an environment. Infrastructure code defines parts of the environment itself and the permissions available within it. The latter is not more important in every situation, but it often has a larger blast radius.

## The model imitates the example it finds

Models are good at producing the most probable pattern. Infrastructure security often depends on exactly what the short example leaves out.

The tutorial Dockerfile uses a simple tag because it wants to teach `docker build`. The demo workflow grants a broad permission because it wants to reach deployment. The Terraform module in an old answer opens temporary access because it wants to prove that the connection works.

Each example may make sense inside the text around it. Once absorbed and recombined, that context disappears. What remains is a pattern that compiles.

This helps explain why "create a Dockerfile for this application" produces something functional before it produces something hardened. Running as non-root, pinning images by digest, separating stages, narrowing permissions, and keeping secrets out are requirements that need to be present in the context or in external controls.

But I do not buy the magic fix of adding "do it securely" at the end of the prompt either.

The IOActive study itself found different responses across model families and instruction levels. Security prompts helped in some configurations. In others, they barely changed the result or made the score worse. A prompt is useful input. It is not executable policy.

## The queue should follow the file, not the author's declaration

Labeling a change as AI-generated helps. I still support that metadata because it gives the reviewer context and may help during an investigation.

Provenance cannot be the only trigger, though.

GitLab's [2026 AI Accountability Report](https://about.gitlab.com/press/releases/2026-06-23-gitlab-research-reveals-organizations-are-generating-ai-code-faster-than-they-can-control-it/) surveyed 1,528 developers and technology buyers. Among respondents, 43% said they could not reliably distinguish AI-generated code from code written by a person. Of those whose organizations experienced an incident in the previous year, 34% could not determine whether generated code contributed to it.

If the gate depends on someone honestly marking "this came from AI," it will fail through forgetfulness, incomplete integration, or mixed editing. After five human changes, who decides whether the file is still "generated"?

I prefer a less elegant and more reliable rule: **the file path defines the minimum review level**.

Did the change touch `Dockerfile`, `.github/workflows/`, `terraform/`, Helm, Kubernetes, an IAM policy, or deployment configuration? The pull request enters the infrastructure and security queue, whether an agent wrote it, a person wrote it, or both did.

Provenance adds context. The path determines the control.

## How I would build that queue

A different queue does not have to mean a committee waiting for a meeting. It means a different set of owners, checks, and evidence.

### Explicit ownership

Infrastructure files need clear owners. `CODEOWNERS` can require review from the platform or security team for critical directories. The rule should apply to every author and should not be removable by the same pull request trying to bypass it.

### Diff the effect, not only the text

For Terraform, I want to see the plan, not only the HCL. For Kubernetes, I want the rendered manifest. For policies, I want to know which actions and resources were added. For an image, I want the package list, effective user, resolved base, and scanner result.

The reviewer needs to see what will change in the system.

### Type-specific gates

Each kind of file calls for its own checks:

- Dockerfile: approved and pinned base image, multi-stage build where appropriate, non-root user, no secret in a layer, and an image scanner;
- CI/CD: actions pinned to a full commit SHA, minimum token permissions, no untrusted-code execution in a privileged context, and restricted secrets;
- Terraform: `fmt`, `validate`, plan, configuration scanner, policy against the plan, and separate approval before `apply`;
- Kubernetes and Helm: rendered manifests, admission policies, resource limits, security context, and no plaintext credentials.

[Docker's documentation](https://docs.docker.com/build/building/best-practices/) recommends pinning images by digest to guarantee the same base, using multiple stages to keep build tools out of the final image, and switching to an unprivileged user when the service does not need to run as root.

In GitHub Actions, pinning an action to a full commit SHA is the only documented way to treat it as an immutable release. For Terraform, [run tasks](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks) can evaluate the plan before `apply` and stop execution when a mandatory policy fails.

There is no universal scanner. The value comes from stacking checks that understand the kind of effect being produced.

### Templates before free generation

For sensitive paths, I would rather have an agent adapt a validated template than start with a blank page.

An organization probably already knows which base images it accepts, how it injects secrets, which regions it uses, how it configures logs, and which Terraform modules are approved. Turning those choices into modules, reusable actions, and base images reduces the space in which the model needs to improvise.

The agent remains useful. It fills variables, connects modules, updates versions, and explains the diff. It simply stops reinventing the security boundary with every prompt.

### Approval close to the effect

Merge and deployment do not need to be the same permission.

One person may approve the structure of the code. Another may approve the plan against the environment. Production `apply` can require a separate identity, an appropriate window, and evidence that the reviewed artifact is exactly what will run.

This matters because a safe pull request may become an unsafe deployment if the pipeline recalculates mutable dependencies, pulls a different image, or runs with broader credentials than those used in testing.

## AI can help with review, but it cannot attest to itself

A second agent can look for a missing `USER`, an action without a SHA, a broad permission, or an open port. That is useful. A specialized agent can even explain the plan and highlight changes with the largest blast radius.

But "one model wrote it and another model approved it" does not create enough independence.

Both may share the same insecure examples, miss the same unwritten rule, or be convinced by the same plausible configuration. Stronger validation comes from different sources: a parser, policy engine, scanner, ephemeral environment, integration test, and human judgment.

Use AI to remove mechanical work from review. Do not use a second probabilistic answer as a security certificate for the first.

## The change in habit

The mistake is not allowing an agent to edit infrastructure. I use agents precisely because they can move across application code, tests, automation, and documentation without losing the task's objective.

The mistake is letting that fluidity erase boundaries that still matter.

A small diff can control a powerful credential. A readable configuration can create a public resource. A green pipeline may have just run untrusted code with write access.

So the question in review should not be only "was this code generated by AI?"

Ask:

> If this file is wrong, how far can the error travel?

When the answer includes the supply chain, credentials, networking, or production, the pull request needs a different queue. Not a slower queue on principle. A queue that looks at the right effect, demands the right evidence, and prevents the ease of generating infrastructure from being confused with the safety of operating it.

## Sources

- [The Security Gap in AI-Generated Code, IOActive](https://www.ioactive.com/wp-content/uploads/2026/05/IOA-The-Security-Gap-in-AI-Generated-Code.pdf)
- [The Security Gap in AI-Generated Code, IOActive summary](https://www.ioactive.com/the-security-gap-in-ai-generated-code/)
- [GitLab Research Reveals Organizations Are Generating AI Code Faster Than They Can Control It](https://about.gitlab.com/press/releases/2026-06-23-gitlab-research-reveals-organizations-are-generating-ai-code-faster-than-they-can-control-it/)
- [Docker build best practices](https://docs.docker.com/build/building/best-practices/)
- [Multi-stage builds, Docker Docs](https://docs.docker.com/build/building/multi-stage/)
- [Secure use reference, GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [Securely using `pull_request_target`, GitHub Actions](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target)
- [Format and validate Terraform configuration using the Terraform CLI](https://developer.hashicorp.com/terraform/cli/code)
- [HCP Terraform run tasks](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks)
