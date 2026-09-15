---
title: "O benchmark reinicia o repositório. Seu time não"
description: "Agentes de código parecem mais capazes quando cada tarefa começa a partir de um checkout limpo. Novos benchmarks mostram o custo que aparece quando patches, decisões e dívida técnica seguem para o próximo trabalho."
date: "2026-09-14T19:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - software-engineering
    - evaluation
    - code-review
    - maintainability
url: /o-benchmark-reinicia-o-repositorio-seu-time-nao/
cover: cover.jpg
cover_alt: "Caminho estreito atravessando uma floresta coberta de neve."
cover_credit_name: "Luise and Nic"
cover_credit_url: "https://unsplash.com/photos/a-path-through-a-snowy-forest-with-tall-trees-M2Prs8jBNJ0"
---

Todo benchmark precisa decidir o que permanece entre uma tarefa e outra.

Na avaliação tradicional de coding agents, a resposta costuma ser: nada.

O agente recebe um issue, abre o repositório, escreve um patch e passa nos testes. Depois, o container volta ao commit inicial, o histórico da conversa desaparece e outro problema começa em uma base limpa, normalmente validada por humanos.

No trabalho real, o segundo issue começa no código que o primeiro deixou.

Esse reset parece um detalhe de laboratório. Só que ele muda o objeto medido. Resolver uma tarefa e manter um sistema são capacidades diferentes.

Quando escrevi sobre [avaliar agentes além do "vibes check"](/avaliando-agentes-de-ia-alem-do-vibes-check/), tratei resultado, trajetória, custo e segurança. A pesquisa recente acrescenta uma pergunta anterior a todas elas: por quanto tempo o resultado precisa continuar correto?

**Se o agente vai trabalhar várias vezes no mesmo repositório, a avaliação precisa fazê-lo herdar as próprias decisões**.

Não basta medir se o patch atual ficou verde. É preciso medir se o estado deixado hoje continua sendo uma base utilizável amanhã.

## O reset é uma escolha de medição

Benchmarks como SWE-bench fizeram uma contribuição importante. Eles tiraram a avaliação de código do autocomplete e levaram o problema para repositórios reais, issues, ferramentas e suítes de teste executáveis.

Para comparar modelos, isolar cada tarefa faz sentido. Um checkout limpo reduz ruído. O mesmo bug começa do mesmo commit para todos os candidatos. Uma falha anterior não contamina a próxima medição.

O problema aparece quando transformamos essa escolha experimental numa promessa operacional.

Um score em tarefas isoladas responde a uma pergunta estreita:

> Dado um repositório validado e um issue, qual é a chance de o agente produzir um patch que passe nesta suíte?

Um time que entrega software precisa responder outra:

> Depois de uma sequência de mudanças feitas pelo agente, o repositório ainda preserva comportamento, arquitetura e espaço para a próxima mudança?

O reset não torna o benchmark ruim. Ele torna perigosa a extrapolação.

Cada reset remove exatamente o que manutenção acumula: decisões locais, abstrações incompletas, testes novos, dependências entre arquivos e dívida técnica. O benchmark vê um patch. O time herda uma trajetória.

## Três issues já são suficientes para o score mudar

O [ChainSWE](https://arxiv.org/abs/2607.02606), submetido em julho e revisado em setembro de 2026, foi construído para observar essa diferença. O conjunto reúne 100 cadeias cronológicas, com 304 issues em 54 projetos Python, extraídas de seis benchmarks da família SWE-bench.

O desenho separa três situações.

Na configuração **Oracle**, cada tarefa começa com as correções anteriores feitas por humanos. Na **Seq**, o repositório mantém os patches anteriores do agente, mas a conversa recomeça. Na **Seq+Mem**, tanto o código quanto o histórico da conversa continuam.

Na primeira posição da cadeia, os resultados ficam próximos. Isso é esperado: ainda não existe passado para herdar.

Na terceira posição, a diferença aparece. Em algumas combinações de modelo e gerenciamento de contexto, a taxa de resolução caiu até 70% em relação à configuração Oracle. É queda relativa, não 70 pontos percentuais. O pior resultado não veio de uma sequência de cinquenta releases. As cadeias tinham, em média, pouco mais de três issues.

O dado mais útil está na origem das falhas. Nas execuções sequenciais da configuração Baseline, 48% dos erros nas posições seguintes foram classificados como **chain errors**: o agente falhou no issue atual por causa do estado produzido numa correção anterior. Nos casos em que os autores conseguiram atribuir o erro a um único arquivo compartilhado, omissões anteriores apareceram aproximadamente nove vezes mais que edições excessivas.

Isso descreve um padrão familiar. O agente corrige a função mencionada, mas não completa o refactor nos arquivos que dependem dela. O teste local passa. Duas tarefas depois, outra mudança encontra o refactor ainda incompleto.

Memória de conversa quase não resolveu o problema. Preservar o transcript trouxe ganhos pequenos e inconsistentes. Código acumulado não é apenas contexto que faltou na janela. É estado executável.

Há limites claros. O ChainSWE usa projetos Python e tarefas mineradas de benchmarks existentes. Os próprios autores reconhecem que alguns testes podem exigir detalhes que o texto do issue anterior não tornava inferíveis. O resultado não prova que qualquer agente perderá 70% em qualquer repositório.

Ele mostra algo mais específico: o desempenho de uma tarefa isolada não permanece estável só porque o modelo é o mesmo.

## Passar no teste ainda pode deixar o patch inaceitável

Tempo não é a única coisa que o reset esconde.

O [SWE-Gate](https://arxiv.org/abs/2609.04167), submetido em setembro de 2026, acrescenta restrições derivadas de comentários reais de code review. O benchmark tem 303 instâncias em 75 repositórios Python e separa testes funcionais de testes para essas restrições.

Nos experimentos com quatro backends de LLM sob o mesmo scaffold, 644 correções passaram nos testes funcionais. Destas, 221 falharam nas restrições de review. Isso representa 34,3% dos patches funcionalmente verdes.

O número não significa que um terço de todo código de agente será rejeitado. As instâncias foram construídas ao redor das restrições e não reproduzem toda a conversa original de um pull request. Ainda assim, a separação é valiosa.

Uma suíte pode confirmar que o erro foi corrigido e continuar sem verificar:

- o tipo exato da exceção;
- a ordem estável de um resultado;
- o fechamento de um recurso;
- a compatibilidade de um schema;
- o escopo completo da correção;
- a compatibilidade com um comportamento anterior.

Essas exigências costumam morar no review porque não cabem apenas no teste funcional do issue. Quando o benchmark as ignora, ele mede "funcionou" e chama isso de "mudança aceita".

São estados diferentes.

## O patch verde também deixa resíduos

O [SWE-STEPS](https://arxiv.org/abs/2604.03035) chega ao mesmo problema por outro caminho. O trabalho organiza 168 tarefas, cobrindo 963 pull requests em seis repositórios Python, em sequências de três a onze PRs. Em vez de descartar o estado, ele acompanha regressões e saúde do repositório ao longo da evolução.

Nos subconjuntos avaliados, a configuração isolada superestimou a taxa de resolução em até 20 pontos percentuais. Na análise Mini, usando a configuração Global e cadeias com mais de cinco PRs, os autores também compararam complexidade cognitiva e dívida técnica com SonarQube. Em Conan, Haystack e Moto, o código produzido pelos agentes terminou com métricas piores que as implementações humanas.

Esse segundo resultado merece cuidado. A análise de saúde foi feita sobre subconjuntos, em poucos repositórios, com métricas estáticas que não equivalem a manutenibilidade por inteiro. SonarQube não conhece a arquitetura que o time quer construir.

Mas o sinal importa porque apareceu mesmo em casos de alto desempenho funcional.

Dívida técnica não deixa de existir quando o autor é um agente. Se o volume de geração cresce mais rápido que a capacidade de [revisar e entender as mudanças](/quando-commits-escalam-mais-rapido-que-reviews/), esse passivo pode acumular mais rápido que a correção.

Um patch verde ainda pode aumentar o custo da próxima mudança.

## O trabalho humano entre tarefas é um subsídio escondido

Existe uma forma simples de fazer um agente parecer melhor: deixar uma pessoa arrumar o repositório antes de cada nova delegação.

O desenvolvedor corrige o teste frágil, remove a abstração duplicada, atualiza a documentação, explica a convenção no `AGENTS.md` e entrega ao agente uma base coerente. A tarefa seguinte começa e o score volta a subir.

Esse trabalho costuma desaparecer da medição.

Chamamos a execução do agente de sucesso e contabilizamos a intervenção humana como manutenção normal. Só que, sem ela, a próxima tarefa talvez falhasse por causa do patch anterior. O benchmark faz essa limpeza com um reset. O time faz com review, retrabalho e contexto carregado por pessoas.

Por isso, eu adicionaria uma métrica pouco elegante: **orçamento de reset**.

Quantas vezes foi necessário:

- reverter uma decisão do agente antes de continuar;
- reescrever código que já passava nos testes;
- reconstruir contexto perdido entre sessões;
- corrigir uma regressão herdada por outra tarefa;
- interromper a sequência e voltar para um commit humano;
- pedir a um mantenedor que prepare o terreno?

Um agente que resolve oito de dez tarefas, mas exige três limpezas humanas entre elas, não tem a mesma autonomia de outro que resolve sete e deixa o repositório utilizável do começo ao fim.

O denominador não pode ser apenas issues fechados. Precisa incluir quantas vezes alguém restaurou as condições para o agente parecer autônomo.

## A unidade de avaliação precisa crescer

Não defendo abandonar benchmarks isolados. Eles continuam úteis para comparar capacidade local, custo e regressões entre versões de modelo.

Defendo parar de usá-los sozinhos quando a implantação pretendida é contínua.

Se eu estivesse avaliando um coding agent para trabalhar de verdade num repositório, manteria duas pistas.

A primeira seria isolada. Cada tarefa começa de uma base humana conhecida. Ela mede a capacidade bruta de resolver o problema.

A segunda seria persistente. O agente recebe uma sequência curta de mudanças reais, no mesmo worktree, com a suíte de regressão crescendo e os próprios patches como ponto de partida. Ela mede operação.

Nessa segunda pista, eu registraria:

1. taxa de conclusão da sequência inteira, não apenas média por issue;
2. falhas causadas por patches anteriores;
3. restrições de review atendidas;
4. regressões introduzidas e tempo até detectá-las;
5. intervenção humana entre tarefas;
6. variação de complexidade e dívida como sinais, não como vereditos.

Também manteria uma execução Oracle. Aplicar as mudanças humanas anteriores antes de cada etapa ajuda a separar a dificuldade do issue do dano acumulado pelo agente.

Esse desenho custa mais. Exige sequências representativas, graders que entendem regressão e revisão de falhas. Mas a alternativa é barata apenas na planilha. O custo reaparece no repositório.

## O benchmark começou a medir continuidade

Em 2026, novos benchmarks começaram a trocar o issue isolado por sequências que preservam estado.

ChainSWE pergunta o que acontece quando o agente herda o próprio código. SWE-STEPS observa se a saúde do repositório acompanha a taxa de resolução. SWE-Gate separa teste verde de restrição aceita em review.

Nenhum deles representa sozinho o trabalho de uma empresa. Todos têm amostras, linguagens e graders limitados. Mesmo assim, apontam para uma correção necessária.

Software não é uma coleção de issues independentes. Cada mudança altera o custo da próxima.

Usar agentes continuamente não suspende essa propriedade. Eles precisam ser avaliados no mesmo tempo acumulativo em que o sistema existe.

A pergunta final não é "o agente resolveu este ticket?".

Pergunte:

> Se o próximo ticket começar exatamente do estado que o agente deixou, você ainda chamaria esta execução de sucesso?

## Fontes

- [ChainSWE: Benchmarking Coding Agents on Multi-Bug Software Maintenance](https://arxiv.org/abs/2607.02606)
- [SWE-Gate: Passing Functional Tests Is Not Enough for Software Engineering Agents](https://arxiv.org/abs/2609.04167)
- [Beyond Isolated Tasks: A Framework for Evaluating Coding Agents on Sequential Software Evolution](https://arxiv.org/abs/2604.03035)
