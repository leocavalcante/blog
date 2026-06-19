---
title: 'Quando commits escalam mais rápido que reviews'
description: 'O volume de código está crescendo mais rápido do que a capacidade humana de revisar. O problema não é usar IA, é fingir que review continua com o mesmo custo.'
date: "2026-07-27T10:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - code-review
    - developer-experience
    - software-engineering
    - productivity
url: /quando-commits-escalam-mais-rapido-que-reviews/
cover: cover.jpg
cover_alt: "Duas pessoas trabalhando lado a lado em telas com código."
cover_credit_name: "Alvaro Reyes"
cover_credit_url: "https://unsplash.com/@alvarordesign"
---

Existe uma leitura otimista, e em parte correta, sobre a fase atual do desenvolvimento de software: mais gente programando, mais repositórios, mais pull requests, mais código chegando em produção.

O [GitHub Octoverse 2025](https://github.blog/news-insights/octoverse/octoverse-a-new-developer-joins-github-every-second-as-ai-leads-typescript-to-1/) aponta exatamente nessa direção. O GitHub reportou mais de 180 milhões de desenvolvedores, 630 milhões de repositórios, 121 milhões de novos repositórios em 2025, mais pull requests, mais pushes de código e sinais claros de que ferramentas de IA entraram no fluxo normal de trabalho.

O dado que me interessa está um pouco menos brilhante: enquanto os pull requests criados cresceram 20,4% e os pushes de código chegaram a mais de 986 milhões de commits no ano, os comentários em issues e PRs ficaram praticamente estáveis, com alta de 0,35%. Comentários em commits caíram 27%.

O próprio Octoverse trata isso como sinal observacional, não como prova de causalidade. É a forma correta de ler o dado. Ainda assim, a tensão é difícil de ignorar: a produção de código está acelerando, mas os sinais visíveis de conversa sobre esse código não acompanharam no mesmo ritmo.

Em junho de 2026, essa leitura ficou menos dependente de um relatório anual. O estudo ["Agentic Very Much! Adoption of Coding Agent in New GitHub Projects"](https://arxiv.org/abs/2606.07448) olhou para projetos novos criados depois de uma análise anterior e encontrou adoção de coding agents mais de duas vezes maior, além de uso mais intenso em commits assistidos por IA. A amostra e a metodologia são diferentes do Octoverse, mas a direção é a mesma: a capacidade de produzir diffs está crescendo rápido.

Esse é o problema. Não "IA escreve código ruim". Não "desenvolvedores ficaram preguiçosos". O problema é mais simples e mais chato: review é uma capacidade finita.

## Review não ficou mais barato

Gerar código ficou mais barato. Isso não significa que entender código ficou mais barato.

Um agente pode abrir um PR em minutos. Um desenvolvedor pode pedir uma refatoração grande antes do almoço. Um time pode sair de duas mudanças por semana para dez mudanças por dia. Mas a revisão ainda exige as mesmas coisas de sempre: reconstruir contexto, entender intenção, comparar alternativas, identificar riscos, checar testes, perceber efeitos colaterais e decidir se aquilo deveria entrar no sistema.

A parte cara do review nunca foi ler caracteres. Foi formar julgamento.

Esse custo não desaparece quando o diff é gerado por IA. Em alguns casos, ele aumenta. Código gerado pode estar correto no nível local e estranho no nível do produto. Pode passar no teste existente e reforçar uma abstração ruim. Pode corrigir o bug e duplicar a lógica em três lugares. Pode parecer consistente porque imitou o estilo do repositório, mas ainda assim ter entendido a regra de negócio pela metade.

Quando o custo de produzir cai e o custo de verificar permanece alto, a fila muda de lugar. O gargalo sai da implementação e entra no review.

## O primeiro sistema que quebra é o informal

Muitos times operam review com regras implícitas:

- "Manda pequeno."
- "Chama alguém que conhece a área."
- "Se o CI passou, deve estar quase bom."
- "Se ninguém comentou, dá para mergear."

Isso funcionava melhor quando o volume de mudanças era limitado pelo tempo humano de implementação. A própria escrita manual segurava um pouco o ritmo. Não por virtude, mas por atrito.

Com geração assistida, esse freio enfraquece. O autor consegue produzir mais diffs do que consegue explicar com clareza. O revisor recebe mais PRs do que consegue carregar na cabeça. E o time começa a confundir silêncio com aprovação.

Silêncio em review não é aprovação. Muitas vezes é saturação.

## PR pequeno não é estética, é controle de dano

O pedido por PRs menores costuma ser tratado como preferência pessoal. Não é.

PR pequeno reduz o espaço de incerteza. Ele deixa mais claro o que mudou, por que mudou e onde o risco mora. Também limita o dano quando algo escapa. Um PR de 80 linhas errado costuma ser reversível. Um PR de 3.000 linhas que mistura refatoração, dependência, ajuste de teste, formatação e regra de negócio vira arqueologia antes mesmo de ser mergeado.

Para código gerado ou assistido por IA, eu seria ainda mais rígido:

- mudança de comportamento separada de formatação;
- atualização de dependência separada de refatoração;
- código gerado separado de código escrito à mão;
- arquivos mecânicos, como snapshots ou clientes gerados, em commits próprios;
- descrição do PR explicando a intenção, não apenas listando arquivos.

Isso não é burocracia. É reduzir a quantidade de coisas que o revisor precisa manter simultaneamente na cabeça.

## Rotular código gerado não é acusação

Times que usam IA com maturidade deveriam tratar "gerado por IA" como metadado operacional.

Não para envergonhar o autor. Não para criar uma classe inferior de código. O autor continua responsável pelo diff. A ferramenta não assina commit moralmente, não fica de plantão e não recebe pager.

O rótulo serve para ajustar o modo de revisão.

Se uma mudança foi gerada a partir de um prompt amplo, eu quero saber. Se o agente mexeu em muitos arquivos para resolver um problema pequeno, eu quero saber. Se o humano editou manualmente depois, melhor ainda, diga onde concentrou a intervenção. Isso ajuda o revisor a procurar os tipos certos de falha: interpretação errada de requisito, generalização excessiva, duplicação sutil, teste que valida a implementação em vez do comportamento.

Transparência aqui economiza tempo. Fingir que todo diff nasceu do mesmo processo só piora o ruído.

## Review precisa de orçamento

Se o volume de PRs aumenta, mas o número de revisores e o tempo disponível não aumentam, alguém está pagando a conta. Normalmente é a qualidade da revisão.

Orçamento de review pode ser simples:

- limite de PRs simultâneos por autor;
- limite recomendado de arquivos ou linhas por PR;
- tempo protegido no calendário para revisar;
- política explícita para PRs grandes, como design review antes ou pair review durante;
- rotação de revisores para evitar sempre sobrecarregar as mesmas pessoas;
- dono claro para áreas críticas do código.

O ponto não é transformar review em uma fila burocrática. É admitir que atenção é um recurso. Se o time planeja capacidade para desenvolvimento e não planeja capacidade para revisão, está planejando metade do sistema.

## CI é porteiro, não revisor

CI ajuda muito. Typecheck, testes, lint, análise estática, SAST, checagem de cobertura e validação de contratos reduzem o trabalho humano repetitivo. Quanto mais código for gerado, mais importantes ficam esses gates.

Mas CI não sabe se a mudança deveria existir. Ele não sabe se o fluxo ficou mais confuso, se o nome mascara uma regra de negócio, se o acoplamento novo vai custar caro daqui a dois meses. Ele valida propriedades conhecidas. Review humano lida com julgamento.

O erro é usar CI verde como substituto de entendimento.

O melhor uso de automação em review é tirar do humano o que é mecânico. Formatação, estilo, teste ausente, API quebrada, contrato incompatível, vulnerabilidade óbvia. Isso libera o revisor para perguntas melhores:

- a mudança resolve o problema certo?
- o escopo está honesto?
- o comportamento é testável?
- a abstração ajuda ou só distribui complexidade?
- quem vai manter isso quando o autor não estiver por perto?

## Meça carga de review, não só throughput

Times gostam de medir quantos PRs foram mergeados. É uma métrica conveniente, mas incompleta.

Se você quer saber se o sistema de review está saudável, acompanhe sinais mais próximos da carga real:

- PRs abertos por revisor ativo;
- tamanho mediano dos PRs;
- tempo até primeiro review;
- número de ciclos de re-review;
- PRs mergeados sem comentário humano;
- distribuição de reviews por pessoa;
- idade de PRs esperando aprovação;
- quantidade de mudanças revertidas ou corrigidas logo após merge.

Nenhuma métrica isolada conta a história inteira. Mas um padrão deveria acender alerta: volume de PR subindo, tamanho dos diffs subindo, comentários estáveis ou caindo e poucas pessoas segurando a maior parte dos reviews.

Isso não prova que a qualidade caiu. Prova que o sistema está trabalhando perto do limite.

## Use IA para preparar review, não para fingir que review aconteceu

IA pode ajudar muito no review. Eu gosto de usar ferramentas para resumir diffs, apontar arquivos de maior risco, sugerir casos de teste, comparar comportamento antes e depois, ou procurar inconsistências simples.

Mas existe uma diferença grande entre usar IA para preparar a revisão e usar IA como álibi para não revisar.

Um comentário automático dizendo "looks good" não aumenta confiança. Um resumo que destaca que o PR toca autenticação, cache e migração de dados ajuda bastante. Uma sugestão de teste para um caso limite é útil. Um bot que aprova mudanças sem contexto de produto só empurra o problema para produção.

Automação boa encurta o caminho até o julgamento humano. Automação ruim simula julgamento humano.

## A pergunta honesta

Quando commits escalam mais rápido que reviews, a pergunta não é "como fazemos merge de tudo mais rápido?".

A pergunta é: "qual volume de mudança conseguimos entender de verdade?".

Essa resposta pode ser desconfortável. Talvez o time precise limitar PRs simultâneos. Talvez precise quebrar tarefas com mais disciplina. Talvez precise recusar diffs gerados que chegam grandes demais. Talvez precise investir mais em testes de contrato, ownership e observabilidade. Talvez precise dizer que produtividade sem capacidade de revisão é só estoque de risco.

IA pode aumentar muito a capacidade de escrever software. Ótimo. Mas se a organização não aumentar também a capacidade de revisar, explicar e manter, ela não ganhou velocidade. Ela só moveu trabalho invisível para o futuro.

## Referências

*   [GitHub Octoverse 2025: A new developer joins GitHub every second as AI leads TypeScript to #1](https://github.blog/news-insights/octoverse/octoverse-a-new-developer-joins-github-every-second-as-ai-leads-typescript-to-1/)
*   [Agentic Very Much! Adoption of Coding Agent in New GitHub Projects](https://arxiv.org/abs/2606.07448)
*   [Agentic Much? Adoption of Coding Agents on GitHub](https://arxiv.org/abs/2601.18341)
