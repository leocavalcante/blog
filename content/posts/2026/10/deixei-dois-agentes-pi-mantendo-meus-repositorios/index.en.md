---
title: "I let two Pi agents maintain my repositories. They invented their own work"
description: "Pi Durable kept two autonomous maintainers working for four days, including through an upgrade of Pi itself. With no real demand, they wrote their own issues and merged 693 pull requests."
date: "2026-10-13T15:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - reliability
    - security
    - tooling
    - code-review
url: /en/deixei-dois-agentes-pi-mantendo-meus-repositorios/
cover: cover.jpg
cover_alt: "An office building facade at night, with dozens of lit windows in shades of green and nearly empty rooms."
cover_credit_name: "Yury Orlov"
cover_credit_url: "https://unsplash.com/photos/a-very-tall-building-with-lots-of-windows-at-night-CJvWIcnvrXI"
---

On Friday, October 9, around 11 a.m., I started two autonomous agents in my home lab to maintain two Pi extensions I wrote, pi-subagents and pi-tmux. I stopped both on Tuesday, a little after noon. In between, they merged 693 pull requests, 378 of them on Saturday and Sunday.

Each PR was opened and merged by the agent itself, with no human review. The median time from opening to merging was 2 minutes in pi-tmux and 6 in pi-subagents. In the same period, the two repositories received 664 new issues. Based on the filters I could put together, only nine came from my actual use of the extensions.

On Friday morning, pi-tmux, which names tmux windows after the task at hand, had 738 lines of code outside the tests. By Tuesday, the file that builds, filters, and validates the request to the naming model had 4,364 on its own.

**Pi Durable did its part: the agents went through restarts and an upgrade of Pi itself without losing the session in progress. What went wrong was in the code I wrote around the library. The loop had no source of work other than the agent itself, no state for "nothing to do", and the only boundary I kept depended on a list of formats.**

The numbers come from the two repositories, which are public, and from the agents' session journal. I counted from Friday at 11 a.m. to the agents' last merge on Tuesday at 12:22 p.m., Brasília time. Line counts include comments and blank lines.

## Pi leaves out what you can build

The README describes Pi as a minimal, extensible agent harness that you adapt to your workflow, not the other way around. Mario Zechner started the project and, in a November 2025 post, summed up the rule: if he doesn't need something, it doesn't get built.

Pi stays lean on purpose. The default tools are four: `read`, `write`, `edit`, and `bash`. In that post, Mario counted fewer than 1,000 tokens for the system prompt and tool definitions combined. Pi also does not ask for approval before every tool call. The security documentation says protection comes from limiting the files, credentials, processes, and network the process can reach, and that watching the transcript does not create a security boundary.

The README lists what stays out, such as subagents and plan mode, and suggests asking Pi itself to build what is missing or installing a package that does it your way. Extensions are TypeScript modules loaded into the Pi process, and they register tools, commands, shortcuts, providers, and terminal UI components. The same agent runs interactively, in print or JSON mode, over RPC, or inside an application through the SDK.

Pi 1.0 shipped on October 1, 2026, released by Earendil and the Pi community. My two extensions were born in the following days, in the space the core leaves open.

pi-subagents delegates tasks to isolated Pi agents, one at a time, in parallel, or in a chain. In 2025, Mario's suggestion for subagents was to have Pi call itself through bash, or even inside a tmux session, to watch and interact with the subagent. The extension turns that pattern into a tool. pi-tmux names the tmux window from the task and the session history, and marks windows that are waiting for input.

## Pi Durable records each step before taking the next

Pi Durable shipped alongside Pi 1.0 as an experimental package. Earendil's announcement explains why it exists. Pi was made to run in a terminal, driven by one person. If the process dies, that person looks at what happened and tells it to continue. Pi Durable is a framework for agentic applications that run for a long time, anywhere, survive failures, and let more than one person steer the same agents.

For Earendil, a harness is storage plus the machinery that runs conversations with models, the tools they call, and the environments where those tools execute. Everything the harness runs is a task, from the model call to a tool execution. Each task records a checkpoint before moving on. If the process dies, another process opens the same storage, finds the half-done tasks, and continues each one from its last checkpoint.

After a crash, Pi Durable separates what can be repeated from what cannot. An interrupted model call is sent again, and the partial answer stays in the transcript, marked as aborted. An interrupted tool runs again only if it declares that it is safe to repeat. If it does not, the model receives the call as interrupted, with the output recorded so far, and decides what to do. In my agents, an interrupted `bash` came back that way, and the agent checked git and GitHub again before moving on.

Compaction is also a task, and it runs in the background. When the context gets close to the model's limit, a summary replaces the older messages in the next requests, without deleting anything from storage. According to the announcement, the whole package is about 15,000 lines, without the tests.

My agents' loop, simplified, looks like this:

```ts
const harness = await Harness.open(await openNodeSqliteStorage("/state/session.sqlite"), { models, registry, env: () => env }, context);
const root = await harness.root(context, { agent: { model, thinkingLevel: "max", cwd } });
harness.resume(); // resumes what the previous process left half-done

while (!closing) {
  const pending = progress.submissionId === undefined
    ? undefined
    : await harness.submission(progress.submissionId, context); // the session that was running
  const submission = pending ?? await root.submit(
    { type: "input", content: nudge(progress.session), requestId: `session-${progress.session}` },
    context,
  );
  await saveProgress({ session: progress.session, submissionId: submission.id });
  const result = await submission.wait(context);
  progress = { session: progress.session + 1 };
  await saveProgress(progress);
  if (result.status !== "done") await sleep(backoff()); // only waits after a failure
}
```

Each work session is a submission to the same root conversation. A repeated `requestId` returns the original submission instead of creating another, and the ID saved to a file lets a new process find the session in progress.

## First I fenced the agents in, then I took the fences down

The first version of these maintainers had gates everywhere. Tests ran in isolated jobs without network access or credentials, each released by a separate executor. Before touching code, the agent had to open an issue. The agent then opened a PR, which needed green CI and a separate, read-only review before the merge. One of the agents stalled for about 14 hours on a bug its own rules did not let it fix, and every rule change cost me hours of review.

On Friday, I replaced all of it with a simple design. Each repository got one agent in its own container, with a single Pi Durable conversation stored in SQLite. Each agent had Pi's four tools, root in the container, internet access, a persistent directory, and my GitHub login. Both ran GPT-6 Luna with the thinking level set to max.

The prompt's only hard rule was not to publish secrets or sensitive data. A scanner checked what went out through the configured paths: a wrapper around `gh` and git hooks for commit and push. GitHub push protection served as a backstop.

Friday's prompt asked for the work of a senior maintainer: fix bugs, improve reliability, tests, documentation, developer experience, and performance, and add valuable features that fit the project's purpose. It also asked the agent to open issues for bugs and improvement ideas, merge its own PR when CI passed, and never wait for a human. Each session started with the same reminder to check the current state and keep improving the repository. The next one started as soon as the previous one ended.

On Friday, around noon, I upgraded the Pi packages from 1.0.4 to 1.1.0 while both agents were working. Both resumed the session in progress, and one of them merged a PR about a minute later. By Tuesday, the pi-subagents maintainer had closed 740 sessions and the pi-tmux one 592, each always in the same conversation. When two sessions ended without an answer on Sunday, the loop waited and kept going.

Because the agents used my login, every issue and every PR from those four days shows my username on GitHub.

## The real backlog lasted one hour

When the agents started, there were three open issues. Two came from failures I had seen while using pi-subagents: it rejected the new message types in Pi 1.1.0 and hid the output of failed jobs. The third asked for type-checking of the pi-tmux test suite. Before noon on Friday, all three were closed.

From then on, the queue was whatever the agents wrote. The prompt asked them to keep improving and to open an issue for every improvement idea. They did exactly that.

| | pi-subagents | pi-tmux |
| --- | --- | --- |
| Work sessions | 740 | 592 |
| Issues opened in the period | 181 | 483 |
| Merged PRs | 200 | 493 |
| Median time from opening to merging a PR | 6 min | 2 min |
| Lines of code outside tests, Friday to Tuesday | 2,890 → 10,706 | 738 → 5,659 |
| Lines of tests, Friday to Tuesday | 2,598 → 8,083 | 3,307 → 22,584 |

The Pi sessions I use day to day are instructed to open an issue when one of the extensions fails. I searched the 664 issues for ones in the format of those reports, with the Pi version, environment, and reproduction steps. I found nine. The maintainers wrote the rest themselves, almost always minutes before the PR that closed them.

## Without demand, the agent picks the work that is easiest to prove

pi-tmux sends excerpts of the conversation to a model that picks the window name. On Friday morning, the protection against leaks was one sentence in that model's prompt: no secrets, tokens, or personal information. The concern was legitimate, and the maintainer started by rejecting email addresses in the title.

Next came tokens and keys from Mailgun, Artifactory, Fly.io, Dynatrace, 1Password, Databricks, and Linear. Document numbers followed: US SSNs, Australian TFNs, Japanese My Numbers, British NHS numbers, and even the French NIR of people born in Corsica. Each format became an issue, a test, a PR, and a merge after CI passed. By my count of the titles, 297 of the 493 pi-tmux PRs dealt with filtering credentials and personal data.

Each PR, on its own, is defensible. Together, the 493 took pi-tmux from 738 to 5,659 lines of code, and its tests from 3,307 to 22,584. The extension's job is still the same: naming a window.

In pi-subagents, the same pattern showed up in features. The agent merged 23 feature PRs that no user asked for, 12 of them to find and filter agent definitions: by name, description, allowed tools, model, environment variables, and tags. The description of the tool that lists agents, sent to the model in every session with the extension loaded, now explains Unicode 17.0 case folding, with Greek sigma and German ß.

Meanwhile, a real bug waited. On Saturday, one of my sessions opened a pi-tmux issue: when the naming model replied with more than one line, the window title did not change. The maintainer closed the issue five minutes later with a better warning message, and the title still did not change. On Sunday, another of my sessions filed the same complaint. Only then did a retry arrive.

None of the 693 PRs had a human review, and nobody could keep up with more than 170 a day, the average over those four days. In [When Commits Scale Faster Than Reviews](/en/quando-commits-escalam-mais-rapido-que-reviews/), I treated CI as a gatekeeper. Here, the gatekeeper checked tests the agent itself had just written.

## Banning invented work in the prompt solved half of it

On Monday night, I rewrote the prompt. The agent could add a feature only at a user's request and open an issue only for a reproduced bug or a user request. Nor could it add detection rules, identifier formats, validators, or categories on its own. Before opening an issue or PR, it had to reproduce the problem and cite the file, the line, or the output.

pi-tmux stopped adding formats and started fixing what it had built. Between 3 a.m. and 12:22 p.m. on Tuesday, it opened 24 PRs, and 17 of them adjusted edge cases and false positives in the filter: a token cut off at the limit of the text sent to the model, prose attached to a token, whitespace at the edge. Saturday's code became Tuesday's backlog, the same residue I described in [The benchmark resets the repository. Your team does not](/en/o-benchmark-reinicia-o-repositorio-seu-time-nao/).

pi-subagents ran out of work. Between 12:52 a.m. and 4:14 a.m. on Tuesday, its maintainer ran 509 sessions, one every 17 seconds at the median. Almost all of them ended with the same summary: main clean, no open PRs, the only open issue waiting for a GitHub runner migration, nothing new within scope. Each one still went through the model with thinking at max.

The loop waits only after a failure. When a session concludes there is nothing to do, it ends successfully, and the next one starts right away.

In July, I wrote that [the important boundaries need to live outside the prompt](/en/excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/). On Monday, I put the scope rule in the prompt, and it behaved like a prompt. It changed what the model chose, and the loop stayed the same.

## The only boundary depended on a list

On Saturday at 12:20 p.m., the pi-tmux maintainer opened an issue asking to filter Resend API keys. The body carried a value shaped like a Resend key.

The scanner that guarded the agent's publications knew seven formats, plus the exact values of the credentials the agent used. Resend was not among them, and the issue was published. Two seconds later, GitHub secret scanning, which also reads issue bodies and comments, opened an alert with unknown validity.

The maintainer did not find the alert until early Tuesday. It removed the value from the visible body, reopened the issue, and recommended revoking the key if it was real. By its own assessment, the value did not look like a test fixture or an obvious placeholder. On Tuesday afternoon, I confirmed the value was only an example and closed the alert as a false positive. A real key would have been published the same way and would have stayed in the issue's edit history, as the example did.

Over four days, the maintainer opened almost 300 PRs to teach pi-tmux to recognize credentials and personal data, while its own scanner stayed at seven formats. On Tuesday, I stopped both agents, and the scanner gained an eighth format, the same fix the pi-tmux maintainer had spent the weekend making.

## What durability does not decide

Pi Durable did its part. Over those four days, no restart or upgrade made an agent lose the session in progress. The three failures showed up in the code I wrote around the library, and more durability would not fix any of them.

The source of work has to come from outside the agent: a user's issue, a red CI run, a new Pi release, a dependency alert. When that queue is empty, "nothing to do" is a valid result.

The loop needs an idle state. Instead of starting a new session every 17 seconds, it can sleep until an event arrives, such as a new issue, a comment, or a failed CI run. When the event arrives, the agent is still free to decide what to do.

The publication boundary cannot depend only on the formats someone remembered to list. An issue body is publication, like a push. A value that looks like a secret, in a known format or not, should not go out, not even as an example.

I don't buy merged-PR counts as a measure of an autonomous maintainer. Of the 664 issues, the nine that came from real use were the only ones with someone waiting on the other side, and the maintainer closed each of them in under 40 minutes. That is the work I want to measure.

> If your agent wakes up tomorrow with no open issues, what does the loop tell it to do?

## Sources

- [Mario Zechner: What I learned building an opinionated and minimal coding agent](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/)
- [Pi: README](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/README.md)
- [Pi: How Pi Works](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/how-pi-works.md)
- [Pi: CLI and default tools](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/cli.md)
- [Pi: Run Pi safely](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/security.md)
- [Earendil: Pi Durable](https://earendil.com/posts/pi-durable/)
- [Pi Durable: README](https://github.com/earendil-works/pi/blob/main/packages/durable/README.md)
- [leocavalcante/pi-subagents](https://github.com/leocavalcante/pi-subagents)
- [leocavalcante/pi-tmux](https://github.com/leocavalcante/pi-tmux)
- [GitHub Docs: About secret scanning](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning)
- [When Commits Scale Faster Than Reviews](/en/quando-commits-escalam-mais-rapido-que-reviews/)
- [Excessive Agency Is a Reliability Bug, Not Only a Security Risk](/en/excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/)
- [The benchmark resets the repository. Your team does not](/en/o-benchmark-reinicia-o-repositorio-seu-time-nao/)
