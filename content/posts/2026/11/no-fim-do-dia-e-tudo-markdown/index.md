---
title: "No fim do dia, é tudo Markdown"
description: "SDD, spec-first, AI-native SDLC e context engineering multiplicam nomes e arquivos. No fim, continuam sendo instruções em Markdown para um LLM; prompt engineering segue como a competência mais subestimada da AI engineering."
date: "2026-11-12T10:15:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - prompt-engineering
    - tooling
url: /no-fim-do-dia-e-tudo-markdown/
cover: cover.png
cover_alt: "Ilustração com cartões de papel rotulados com nomes de arquivos Markdown, como AGENTS.md, CLAUDE.md, SKILL.md, spec.md e plan.md, convergindo para uma fenda estreita iluminada; do outro lado sai um único bloco de texto simples com instruções."
cover_credit_name: ""
cover_credit_url: ""
---

O post de lançamento do Kiro, em 14 de julho de 2025, abre com: “I'm sure you've been there: prompt, prompt, prompt, and you have a working application. ... But getting it to production requires more.” Kiro acerta ao separar um protótipo que funciona do trabalho de levar software à produção. O que eu não compro é o salto de “a produção exige mais” para “o agente precisa de uma disciplina nova para receber instruções”. Quando o agente entra em cena, alguém ainda precisa escrever o que ele deve fazer.

“Just prompt” pode soar como se o trabalho fosse só escrever uma frase curta na caixa de chat. Prompt engineering inclui escolher o texto que o modelo recebe, dizer com precisão o que espero e reconhecer quando uma instrução deixa margem para interpretações diferentes. O nome do arquivo não tira essa decisão do caminho. Às vezes, só faz parecer que o texto já veio pronto de uma disciplina nova.

## Um nome novo a cada poucos meses

A conversa ganhou vários nomes. Hoje falamos de SDD, spec-first, context engineering, Agent Skills, AI-native SDLC. E os nomes dos arquivos se acumulam junto: `AGENTS.md`, `CLAUDE.md`, `SKILL.md`, `requirements.md`, `design.md`, `constitution.md`, `intent.md`, `spec.md`, `plan.md`, `tasks.md`. A mensagem inicial pode ser curta; o conjunto de instruções cresce. Nos dois casos, alguém escolheu palavras para orientar um LLM.

A Anthropic anunciou Claude Code em 24 de fevereiro de 2025. No fim de junho de 2025, Tobi Lütke preferiu “context engineering” a “prompt engineering”, Andrej Karpathy amplificou o termo, e Simon Willison registrou os dois movimentos em 27 de junho. Tobi e Karpathy têm razão sobre o escopo: o modelo recebe mais que a frase digitada no chat. Kiro lançou specs em 14 de julho de 2025; a documentação lista `requirements.md`, `design.md` e `tasks.md`. O registro da Agentic AI Foundation marca 19 de agosto de 2025 como o primeiro commit de `AGENTS.md`. GitHub anunciou o Spec Kit em 2 de setembro de 2025, e o projeto usa `constitution.md`, `spec.md`, `plan.md` e `tasks.md`.

Em 16 de outubro de 2025, a Anthropic publicou Agent Skills. O formato virou padrão aberto em 18 de dezembro de 2025. Em 21 de agosto de 2026, a empresa publicou o AI-native SDLC playbook com `intent.md` → `spec.md` → `plan.md`; no mesmo dia, o Spec Kit chegou à versão 1.0. Em dezoito meses, o vocabulário foi de prompt para context engineering, specs, skills e SDLC nativo de IA. A sigla muda. O sufixo continua `.md`.

## Dentro do arquivo, só instrução

O playbook da Anthropic, publicado em 21 de agosto de 2026, traz um exemplo de `CLAUDE.md` com esta frase: “Run all three before reporting any task complete, and paste the output.” Eu poderia digitar exatamente isso numa conversa com o agente. O modelo recebe o mesmo verbo no imperativo e as mesmas palavras. A frase também define quando o agente pode afirmar que terminou: depois de executar as três ações e colar a saída. Na amostra, as três ações são build, test e lint. Alguém escolheu esse critério e o escreveu em linguagem direta.

Meu `AGENTS.md` global tem cinco linhas: Conventional Commits, atribuir meus pull requests a mim, incluir um trailer `Signed-off-by`, não usar `Co-Authored-By` e não abrir draft PRs. São as regras que eu quero que o agente siga, sem uma teoria por trás de cada linha. O que dá trabalho é decidir o que merece virar instrução, escrever sem deixar a regra ambígua e perceber se ela conflita com outra.

As cinco linhas cobrem coisas diferentes: uma convenção de commit, quem recebe o PR, o trailer que acompanha, duas proibições. Cada uma descreve uma ação ou limite. Esse detalhe me interessa mais do que o nome do arquivo, porque é o texto que especifica o que quero que o agente faça. A habilidade está em escrever cada regra com o escopo certo.

Uso Pi, sobre o qual já escrevi em [dois agentes mantendo meus repositórios](/deixei-dois-agentes-pi-mantendo-meus-repositorios/). Mario Zechner conta que o system prompt e as definições de ferramentas do Pi somam menos de 1.000 tokens. Esse número deixa visível uma camada que às vezes some da discussão: alguém escreveu as instruções que orientam o agente, e o modelo trabalha com esse texto.

## Escrever instrução continua sendo prompt engineering

Em agosto de 2025, publiquei [A Engenharia de Prompt e a Variação entre LLMs](/a-engenharia-de-prompt-e-a-variacao-entre-llms/), sobre a variação entre modelos e a necessidade de adaptar a instrução. Esse ponto continua relevante: o mesmo nome de arquivo não faz dois LLMs responderem da mesma forma ao mesmo texto. Um ano depois, há mais nomes em volta da mesma tarefa, mas continua sendo necessário escrever para o modelo específico que vai receber o pedido.

O InstructGPT torna explícita a ligação entre texto e comportamento. Ouyang et al. ajustaram GPT-3 com demonstrações escritas por avaliadores e comparações entre respostas para aproximar as saídas da intenção de quem pede. Os autores também registraram erros simples. Treinar um modelo para seguir instruções não elimina a necessidade de escrever instruções melhores. É justamente por isso que eu não trato essa habilidade como um detalhe de interface.

No guia de prompting do GPT-5, a OpenAI diz que o modelo segue instruções com “surgical precision”. O guia também alerta que instruções vagas ou contraditórias podem prejudicar o GPT-5 mais do que outros modelos. Parte dos tokens de raciocínio vai para tentar conciliá-las. O mecanismo é fácil de reconhecer: duas frases podem pedir coisas incompatíveis, e o nome do arquivo não define qual delas deve vencer.

## Oito arquivos para mostrar uma data

Num exemplo de Spec Kit publicado pela [Marmelab](https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html), uma solicitação para exibir a data atual em um aplicativo de controle de horas gerou 8 arquivos e 1.300 linhas de texto. Na análise de Kiro, spec-kit e Tessl, Birgitta Böckeler escreve: “To be honest, I’d rather review code than all these markdown files.” Ela também relata o que observou ao testar essas ferramentas: “Even with all of these files and templates and prompts and workflows and checklists, I frequently saw the agent ultimately not follow all the instructions.” O segundo relato importa porque a quantidade de instruções e a adesão do agente são coisas diferentes.

O over-engineering aparece na cerimônia em volta da instrução. Um método pode acrescentar templates para preencher, comandos para rodar, gates para passar e documentos para revisar e manter em sincronia. A cerimônia cresce para quem escreve e para quem revisa.

## E ainda tem o context rot

A Chroma avaliou 18 LLMs em tarefas de contexto longo e observou que o desempenho ficou menos confiável conforme o input cresceu. O preprint da ETH Zurich sobre `AGENTS.md` avaliou dois benchmarks com agentes de código. O SWE-bench Lite reúne 300 tarefas de 11 repositórios Python populares sem arquivos de contexto mantidos por desenvolvedores; o CTXbench tem 138 instâncias de 12 repositórios com esses arquivos. Considerando arquivos gerados por LLM e arquivos mantidos por desenvolvedores, os autores não encontraram melhora geral na taxa de resolução. Para arquivos gerados por LLM, o custo médio de inferência por tarefa subiu 20% no SWE-bench Lite e 23% no CTXbench. Na análise dos rastros, os agentes seguiam as instruções e passavam a explorar e testar mais.

Josh Bleecher Snyder escreve que “Most AGENTS.md should be deleted.” No artigo, ele defende transmitir intenção, nuance e detalhes operacionais em vez de transformar cada preferência numa regra. Mesmo essa alternativa exige escolhas de prompt. O rótulo da camada muda; alguém continua escrevendo para o modelo.

O próximo arquivo que alguém acrescentar ainda é um prompt: just prompt, just f*cking prompt. Escreva-o como prompt para o modelo que vai recebê-lo.

## Fontes

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
