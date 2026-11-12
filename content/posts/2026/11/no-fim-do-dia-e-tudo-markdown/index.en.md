---
title: "At the End of the Day, It’s All Markdown"
description: "SDD, spec-first, AI-native SDLC, and context engineering multiply method names and files. In the end, they are still Markdown instructions for an LLM; prompt engineering remains the most underrated skill in AI engineering."
date: "2026-11-12T10:15:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - prompt-engineering
    - tooling
url: /en/no-fim-do-dia-e-tudo-markdown/
cover: cover.png
cover_alt: "Illustration of paper cards labeled with Markdown filenames such as AGENTS.md, CLAUDE.md, SKILL.md, spec.md and plan.md converging into a narrow lit slot; a single block of plain-text instructions comes out the other side."
cover_credit_name: ""
cover_credit_url: ""
---

The Kiro launch post on July 14, 2025 opens with: “I'm sure you've been there: prompt, prompt, prompt, and you have a working application. ... But getting it to production requires more.” Kiro is right to distinguish a working prototype from the work of taking software to production. What I don't buy is the leap from “production requires more” to “the agent needs a new discipline for receiving instructions.” Once the agent is involved, someone still has to write what it should do.

“Just prompt” can sound as if the work were only writing one short sentence in a chat box. Prompt engineering includes choosing the text the model receives, stating what I expect clearly, and recognizing when an instruction leaves room for different interpretations. A filename doesn't remove that decision. Sometimes it makes the text look as though it came ready-made from a new discipline.

## A new name every few months

The conversation has acquired a lot of names. We now talk about SDD, spec-first, context engineering, Agent Skills, and AI-native SDLC. The filenames multiply too: `AGENTS.md`, `CLAUDE.md`, `SKILL.md`, `requirements.md`, `design.md`, `constitution.md`, `intent.md`, `spec.md`, `plan.md`, `tasks.md`. The initial message can be short while the set of instructions grows. In both cases, someone chose words to guide an LLM.

Anthropic announced Claude Code on February 24, 2025. In late June 2025, Tobi Lütke preferred “context engineering” to “prompt engineering,” Andrej Karpathy amplified the term, and Simon Willison recorded both moves on June 27. Tobi and Karpathy are right about the scope: the model receives more than the sentence typed into chat. Kiro launched specs on July 14, 2025; its documentation lists `requirements.md`, `design.md`, and `tasks.md`. The Agentic AI Foundation record marks August 19, 2025 as the first commit of `AGENTS.md`. GitHub announced Spec Kit on September 2, 2025, and the project uses `constitution.md`, `spec.md`, `plan.md`, and `tasks.md`.

Agent Skills appeared on October 16, 2025, published by Anthropic. The format became an open standard on December 18, 2025. On August 21, 2026, the company published its AI-native SDLC playbook with `intent.md` → `spec.md` → `plan.md`; Spec Kit reached version 1.0 the same day. Over eighteen months, the vocabulary went from prompt to context engineering, specs, skills, and AI-native SDLC. The acronym changes. The suffix is still `.md`.

## Inside the file, just instructions

Anthropic's playbook, published on August 21, 2026, includes a `CLAUDE.md` example with this sentence: “Run all three before reporting any task complete, and paste the output.” I could type exactly that in a conversation with the agent. The model receives the same imperative verb and the same words. The sentence also sets when the agent can claim it is done: after running all three and pasting the output. In the example, the three are build, test, and lint. Someone chose that completion criterion and wrote it directly.

My global `AGENTS.md` has five lines: Conventional Commits, assign pull requests to me, include a `Signed-off-by` trailer, no `Co-Authored-By`, and no draft PRs. Those are rules I want the agent to follow, without a theory behind each line. The work is deciding what deserves to become an instruction, writing it without ambiguity, and noticing when it conflicts with another rule.

The five lines cover different things: a commit convention, who gets the PR, a trailer, and two prohibitions. Each describes an action or a boundary. That detail matters more to me than the filename because the text specifies what I want the agent to do. The skill is writing each rule with the right scope.

I use Pi, and I wrote about [two agents maintaining my repositories](/en/deixei-dois-agentes-pi-mantendo-meus-repositorios/). Mario Zechner reports that Pi's system prompt and tool definitions together total fewer than 1,000 tokens. That number makes one layer visible that can disappear from the discussion: someone wrote the instructions that guide the agent, and the model works with that text.

## Writing instructions is still prompt engineering

In August 2025, I published [Prompt Engineering and Variation Across LLMs](/en/a-engenharia-de-prompt-e-a-variacao-entre-llms/) about model variation and the need to adapt instructions. That point still matters: sharing a filename does not make two LLMs respond the same way to the same text. A year later, more names surround the same task, but the writer still has to write for the specific model receiving the request.

InstructGPT makes the connection between text and behavior explicit. Ouyang et al. fine-tuned GPT-3 on demonstrations written by labelers and comparisons between responses to bring its outputs closer to the requester's intent. The authors also reported simple mistakes. Training a model to follow instructions does not remove the need to write better instructions. That's why I don't treat this skill as an interface detail.

OpenAI's GPT-5 prompting guide says the model follows instructions with “surgical precision.” It also warns that vague or contradictory instructions can hurt GPT-5 more than other models. Some of its reasoning tokens go toward reconciling them. The mechanism is familiar: two sentences can ask for incompatible things, and the filename does not decide which one wins.

## Eight files to show a date

In a Spec Kit example published by [Marmelab](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html), a request to display the current date in a time-tracking app produced 8 files and 1,300 lines of text. In her analysis of Kiro, spec-kit, and Tessl, Birgitta Böckeler writes: “To be honest, I’d rather review code than all these markdown files.” She also reports what she saw while testing those tools: “Even with all of these files and templates and prompts and workflows and checklists, I frequently saw the agent ultimately not follow all the instructions.” Her second observation matters because the amount of instruction and the agent's adherence are different things.

Overengineering shows up as ceremony around the instruction. A method may add templates to fill out, commands to run, gates to pass, and documents to review and keep in sync. Ceremony grows for the person writing and the person reviewing.

## And then there's context rot

Chroma evaluated 18 LLMs on long-context tasks and found that performance became less reliable as the input grew. The ETH Zurich preprint on `AGENTS.md` evaluated two coding-agent benchmarks. SWE-bench Lite includes 300 tasks from 11 popular Python repositories with no developer-provided context files; CTXbench has 138 instances from 12 repositories that include developer-committed files. Across LLM-generated and developer-maintained context-file conditions, the authors found no general improvement in resolution. For LLM-generated files, average inference cost per task rose 20% on SWE-bench Lite and 23% on CTXbench. In their trace analysis, agents followed instructions and did more exploration and testing.

Josh Bleecher Snyder writes, “Most AGENTS.md should be deleted.” In the article, he argues for communicating intent, nuance, and operational details instead of turning every preference into a rule. Even that alternative requires prompt choices. The layer may get a new name; someone still has to write for the model.

The next file someone adds is still a prompt: just prompt, just f*cking prompt. Write it as a prompt for the model that will receive it.

## Sources

- [Anthropic: Claude 3.7 Sonnet and Claude Code](https://www.anthropic.com/news/claude-3-7-sonnet)
- [Simon Willison: Context engineering](https://simonwillison.net/2025/Jun/27/context-engineering/)
- [Kiro: Introducing Kiro](https://kiro.dev/blog/introducing-kiro/)
- [Kiro: Specs](https://kiro.dev/docs/specs/)
- [Agentic AI Foundation: AGENTS.md](https://aaif.io/projects/agents-md)
- [GitHub: Spec-driven development with AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Anthropic: Equipping agents with Agent Skills](https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills)
- [Agent Skills standard](https://agentskills.io/)
- [Anthropic: The AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook)
- [GitHub Spec Kit: History](https://github.github.io/spec-kit/overview/history.html)
- [Mario Zechner: What I learned building an opinionated and minimal coding agent](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/)
- [Ouyang et al.: Training language models to follow instructions with human feedback, arXiv:2203.02155](https://arxiv.org/abs/2203.02155)
- [OpenAI: GPT-5 prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide)
- [Marmelab: Spec-Driven Development: The Waterfall Strikes Back](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html)
- [Birgitta Böckeler: Understanding Spec-Driven-Development](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Chroma: Context Rot: How Increasing Input Tokens Impacts LLM Performance](https://www.trychroma.com/research/context-rot)
- [Gloaguen et al.: Evaluating AGENTS.md, arXiv:2602.11988](https://arxiv.org/abs/2602.11988)
- [Josh Bleecher Snyder: Prompt Engineering Is Dead, but Claude Still Tries](https://blog.exe.dev/prompt-engineering-is-dead)
