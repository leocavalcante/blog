---
title: "O próximo salto do desenvolvimento com IA: da assistência à orquestração"
description: "A próxima onda não é apenas escrever código com um copiloto. É coordenar agentes supervisionados, contexto, testes e limites ao longo de todo o ciclo de desenvolvimento."
date: "2026-08-11T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - software-engineering
    - developer-experience
    - reliability
url: /o-proximo-salto-do-desenvolvimento-com-ia-da-assistencia-a-orquestracao/
cover: cover.jpg
cover_alt: "Laptop exibindo código-fonte sobre uma mesa, representando a transição da assistência de código para a orquestração de agentes."
cover_credit_name: "Bayu Syaits"
cover_credit_url: "https://unsplash.com/photos/laptop-and-phone-on-a-desk-with-coding-software-open-oYzjGQ7LCVE"
---

Quando alguém pergunta qual será a próxima tendência em IA e desenvolvimento de software, a resposta mais fácil é apontar para outro modelo, outro editor ou outra promessa de código gerado a partir de uma frase.

Olhando para adoção, pesquisa e uso real, a mudança mais importante parece menos cinematográfica: o desenvolvimento vai deixar de usar IA apenas para escrever código e passará a usá-la para **coordenar mudanças verificáveis ao longo de todo o ciclo de entrega**.

Não é o fim do desenvolvedor. É uma mudança na unidade de trabalho. O centro deixa de ser a linha de código ou a função e passa a ser a tarefa supervisionada: entender um problema, propor uma alteração, implementá-la, testá-la, abrir um pull request e deixar evidências suficientes para alguém decidir se aquilo deve seguir adiante.

## O ticket virou a unidade de trabalho

Um copiloto tradicional sugere a próxima linha. Um agente de código recebe um objetivo maior: corrigir um bug, adicionar uma feature, atualizar uma dependência ou investigar uma falha no pipeline.

Essa diferença parece apenas uma questão de interface, mas muda o fluxo. O agente precisa navegar pelo repositório, escolher arquivos, executar comandos, interpretar erros e decidir quando a tarefa está pronta.

Os sinais de adoção já apontam nessa direção. Na [pesquisa de pulso do Stack Overflow de 2026](https://stackoverflow.blog/2026/05/27/agents-on-leash-agentic-ai-remains-mostly-single-agent-and-monitored-at-work/), o uso de agentes no trabalho passou de 31% para 59% em um ano. Mas 63% das pessoas ainda raramente ou nunca deixam um agente operar completamente sozinho. A maioria dos fluxos continua usando um único agente, com monitoramento humano.

Isso é importante porque separa duas ideias que costumam ser tratadas como sinônimas:

- **delegação:** o agente executa uma parte do trabalho;
- **autonomia:** o agente escolhe objetivos, limites e consequências sem supervisão relevante.

A primeira já está se tornando rotina. A segunda ainda não é o modelo operacional padrão.

## O agente não é autônomo. É supervisionado

Uma [análise da Anthropic](https://www.anthropic.com/research/claude-code-expertise?level=0) de aproximadamente 400 mil sessões do Claude Code ajuda a mostrar como essa colaboração acontece. Em uma sessão típica, a pessoa toma a maior parte das decisões de planejamento, enquanto o agente toma a maior parte das decisões de execução.

Em outras palavras, a pessoa decide o que construir, qual problema importa e o que conta como concluído. O agente decide quais arquivos mudar, quais comandos executar e como transformar a intenção em uma alteração concreta.

Esse arranjo é mais realista do que a imagem do “engenheiro que aperta um botão”. A supervisão não desaparece; ela muda de lugar. Em vez de acompanhar cada caractere, o desenvolvedor precisa definir contexto, limites, critérios de aceitação e pontos de parada.

O agente passa a ser um colaborador assíncrono com ferramentas limitadas. Ele pode trabalhar enquanto a pessoa faz outra coisa, mas precisa devolver um resultado que possa ser inspecionado: diff, testes, logs, decisões tomadas, dúvidas e riscos conhecidos.

## O próximo gargalo é o contexto

Quanto mais o agente trabalha sozinho, menos o prompt isolado consegue explicar. Ele precisa saber como o repositório é organizado, quais comandos são confiáveis, quais decisões arquiteturais não podem ser quebradas, quais dependências são permitidas, como rodar os testes e quando uma mudança exige aprovação humana.

Esse conjunto é maior do que instrução. É o ambiente operacional do agente.

Por isso, **context engineering** tende a se tornar uma disciplina mais importante do que prompt engineering. O trabalho consiste em selecionar e manter o contexto certo para cada etapa: documentação, código, memória, estado da tarefa, ferramentas, políticas e evidências.

O movimento já aparece nos próprios produtos. O [Copilot coding agent passou a aceitar arquivos `AGENTS.md`](https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/) na raiz ou em subdiretórios do repositório, junto com outros formatos de instruções. O arquivo não é mágico. Ele apenas torna explícito algo que equipes maduras já fazem para pessoas: documentar como o sistema funciona e como uma mudança deve ser validada.

Em tarefas longas, até o próprio histórico vira um problema. O [paper publicado nos Findings of ACL 2026](https://aclanthology.org/2026.findings-acl.1032/) descreve como o contexto pode crescer demais, sofrer deriva semântica e degradar o raciocínio do agente. A proposta apresentada trata a gestão de contexto como uma ferramenta acionável, e não como uma simples sequência infinita de mensagens.

Um repositório preparado para agentes precisa responder, de forma legível e verificável:

- o que este projeto faz e o que ele não faz;
- quais comandos instalam, testam, formatam e validam uma mudança;
- quais partes do sistema são sensíveis;
- quais convenções não aparecem no compilador;
- quais ações o agente pode executar sozinho;
- como ele deve relatar incerteza, falha e trabalho incompleto.

O arquivo de instruções é só a porta de entrada. O contexto verdadeiro inclui a qualidade do código, dos testes, da documentação e das interfaces que o agente pode acessar.

## A revisão vira o produto

Escrever código está ficando mais barato. Saber se o código resolve o problema certo continua caro.

O [relatório DORA de 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report?e=48754805) encontrou uso de IA próximo da universalidade entre os respondentes e uma percepção ampla de ganho de produtividade. Ao mesmo tempo, a adoção teve relação positiva com throughput e performance do produto, mas relação negativa com estabilidade quando as equipes não tinham testes automatizados, controle de versão e ciclos rápidos de feedback.

Essa é a parte que costuma desaparecer nos anúncios. A IA pode aumentar a quantidade de mudanças produzidas. Sem um sistema de controle, também aumenta a quantidade de mudanças que ninguém conseguiu entender direito.

Os próprios desenvolvedores dão um sinal parecido. Na [pesquisa de IA do Stack Overflow de 2025](https://survey.stackoverflow.co/2025/ai), 87% dos respondentes demonstraram preocupação com a precisão dos agentes e 81% com segurança e privacidade. A questão central não é mais “a IA consegue gerar algo?”. É “quanto custa provar que o resultado é seguro, correto e sustentável?”.

Essa prova precisa ser produzida pelo sistema, não apenas pela confiança do autor. Um pull request gerado por agente deveria carregar, quando aplicável:

- o plano que guiou a mudança;
- os arquivos alterados e o motivo de cada alteração;
- testes executados e testes que não puderam ser executados;
- análise estática, segurança e impacto em dependências;
- decisões deixadas para revisão humana;
- sinais de incerteza ou comportamento ainda não observado.

Isso muda a revisão. O revisor não precisa reler cada linha como se tivesse sido escrita em isolamento. Ele precisa avaliar a evidência, procurar lacunas e decidir se o risco restante é aceitável.

## Não existe um número universal de produtividade

As pesquisas sobre produtividade ainda são contextuais, e isso é uma informação útil.

Experimentos de campo da Microsoft com 4.867 desenvolvedores encontraram aumento de 26% nas tarefas concluídas quando os participantes tinham acesso a um assistente de código. Já o estudo controlado da METR com desenvolvedores experientes de projetos open source observou, para as ferramentas do início de 2025, tarefas 19% mais longas com IA. Em uma atualização posterior, a METR afirmou que seus dados mais recentes eram fracos por efeitos de seleção, embora os desenvolvedores provavelmente estivessem mais acelerados pelas ferramentas novas.

Os estudos não medem exatamente a mesma coisa. Um usa assistentes de completude em ambientes corporativos; o outro observa mantenedores experientes trabalhando em repositórios que já conhecem bem. A conclusão correta não é escolher o percentual que confirma a preferência de cada equipe.

A conclusão é que produtividade não é uma propriedade fixa da ferramenta. Ela depende do tipo de tarefa, do conhecimento do domínio, da qualidade do contexto, da experiência com o agente e do custo de revisar o que ele produz.

Se uma equipe quer saber se ganhou velocidade, precisa medir seu próprio sistema: tempo até uma mudança aceita, reabertura de bugs, retrabalho de revisão, falhas após deploy, custo por alteração e estabilidade. Linhas de código, número de commits e quantidade de sugestões aceitas são sinais fáceis, mas não são o resultado.

## Multiagentes são uma consequência, não o ponto de partida

O [relatório de tendências de agentic coding da Anthropic](https://resources.anthropic.com/ty-2026-agentic-coding-trends-report) prevê a evolução de agentes únicos para equipes coordenadas, agentes de longa duração e revisão automatizada em escala. A direção faz sentido: uma tarefa complexa pode ser dividida entre agentes especializados em implementação, testes, segurança, documentação e operação.

Mas a prática ainda está atrás da previsão. A pesquisa do Stack Overflow mostra que a maior parte das pessoas trabalha com um agente por vez, enquanto uma minoria coordena agentes especializados ou sobrepostos.

Isso sugere uma ordem de investimento. Primeiro, faça um único agente executar bem uma tarefa estreita e verificável. Depois, adicione especialização onde o gargalo for claro. Um conjunto de agentes que compartilha contexto ruim apenas distribui a confusão mais rapidamente.

O problema de orquestração não é apenas chamar vários modelos. É coordenar estado, identidade, permissões, conflitos de edição, orçamento de tokens, recuperação de falhas e responsabilidade pelo resultado.

## O trabalho do desenvolvedor fica mais amplo

É tentador concluir que, se a IA escreve código, o valor do desenvolvedor desaparece. Os dados apontam para uma mudança diferente.

Na análise da Anthropic, sessões com maior conhecimento do domínio têm maior probabilidade de sucesso. A pessoa não precisa dominar todos os detalhes de implementação, mas precisa entender o problema, reconhecer uma solução plausível e perceber quando o agente está seguindo uma interpretação errada.

Uma [pesquisa do Google sobre o comportamento de agentes de software](https://research.google/pubs/towards-ai-as-a-collaborative-partner-a-taxonomy-of-ai-agent-behavior-in-software-engineering/) chegou a uma conclusão parecida por outro caminho. Depois de analisar regras escritas por desenvolvedores e entrevistar profissionais experientes, os autores organizaram as expectativas em quatro grupos: seguir padrões e processos, garantir qualidade e confiabilidade, resolver problemas e colaborar com a pessoa.

Isso descreve bem o novo perfil. O desenvolvedor precisa saber escrever especificações, decompor problemas, projetar sistemas, criar verificações, limitar agência, interpretar telemetria e tomar decisões de produto. Codificar continua importante, porque quem entende o material consegue revisar melhor o trabalho delegado. Mas escrever cada linha deixa de ser a única forma de contribuir.

O desenvolvedor não vira um gerente de prompts. Vira alguém responsável pelo sistema que transforma intenção em mudança confiável.

## Como se preparar agora

Não é necessário esperar uma arquitetura de agentes perfeita. Algumas práticas já produzem benefício com ferramentas simples:

1. **Transforme o repositório em um contrato.** Mantenha instruções, decisões arquiteturais, comandos, convenções e definição de pronto em arquivos versionados. Um `AGENTS.md` curto, com links para a fonte de verdade, é mais útil do que um prompt enorme e desatualizado.
2. **Delegue tarefas verificáveis.** Comece por correções, testes, migrações pequenas, documentação e refatorações com critérios claros. Evite entregar uma decisão de produto ambígua e esperar que o agente invente o contexto que a equipe não escreveu.
3. **Dê agência mínima.** O agente pode ler bastante, mas deve escrever em uma branch, usar ferramentas estreitas e encontrar bloqueios antes de tocar em produção. Permissão ampla não é sinônimo de capacidade.
4. **Converta aceitação em automação.** Testes, linters, análise de tipos, scanners de segurança, testes de contrato e cenários de avaliação devem rodar como parte da tarefa. O agente precisa receber feedback que possa usar para corrigir o próprio trabalho.
5. **Meça mudanças aceitas, não atividade.** Acompanhe tempo de entrega, falhas, rollback, defeitos escapados, retrabalho de revisão e custo. O objetivo é aumentar resultado confiável, não o volume de texto que a equipe consegue produzir.
6. **Mantenha julgamento humano onde existe compromisso.** Produto, arquitetura, segurança, privacidade e mudanças irreversíveis precisam de um responsável identificável. A automação pode preparar a decisão; não deve esconder quem a tomou.

## O risco é construir mais software do que conseguimos manter

Quando o código fica barato, a escassez muda de lugar. O recurso raro passa a ser atenção qualificada: entender o domínio, estabelecer limites, revisar evidências e cuidar do que continuará existindo depois do entusiasmo inicial.

É por isso que eu não apostaria no “vibe coding” como modelo de engenharia para sistemas críticos. Ele é ótimo para explorar uma ideia, construir um protótipo e descobrir perguntas. Mas um produto que precisa sobreviver a mudanças exige contexto, testes, ownership e capacidade de explicar decisões.

A próxima tendência não é uma máquina que substitui o desenvolvedor. É um ambiente em que um desenvolvedor consegue coordenar mais trabalho sem perder a noção de por que cada mudança existe e como saber se ela está correta.

Se um agente abrisse um pull request no seu repositório hoje à noite, ele saberia explicar como provar que a mudança está pronta?

## Referências

- [Agents on a leash: Agentic AI remains mostly single-agent and monitored at work](https://stackoverflow.blog/2026/05/27/agents-on-leash-agentic-ai-remains-mostly-single-agent-and-monitored-at-work/)
- [Agentic coding and persistent returns to expertise](https://www.anthropic.com/research/claude-code-expertise?level=0)
- [2026 Agentic Coding Trends Report](https://resources.anthropic.com/ty-2026-agentic-coding-trends-report)
- [2025 DORA Report: State of AI-Assisted Software Development](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report?e=48754805)
- [AI: 2025 Stack Overflow Developer Survey](https://survey.stackoverflow.co/2025/ai)
- [Towards AI as a Collaborative Partner](https://research.google/pubs/towards-ai-as-a-collaborative-partner-a-taxonomy-of-ai-agent-behavior-in-software-engineering/)
- [Context as a Tool: Context Management for Long-Horizon SWE-Agents](https://aclanthology.org/2026.findings-acl.1032/)
- [The Effects of Generative AI on High-Skilled Work](https://www.microsoft.com/en-us/research/publication/the-effects-of-generative-ai-on-high-skilled-work-evidence-from-three-field-experiments-with-software-developers/)
- [We are Changing our Developer Productivity Experiment Design](https://metr.org/blog/2026-02-24-uplift-update/)
