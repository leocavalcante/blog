---
title: "Agentes de domínio específico: composição contra o agente inchado"
description: "O agente genérico parece simples até virar um contexto gigante com ferramentas demais, permissões demais e custo demais. Agentes de domínio específico trocam esse acúmulo por composição, fronteiras claras e execução mais barata."
date: "2026-07-06T08:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - architecture
    - software-engineering
url: /agentes-de-dominio-especifico-composicao-contra-o-agente-inchado/
cover: cover.jpg
cover_alt: "Diagrama de fluxo de trabalho, briefing de produto e metas de usuário organizados sobre uma mesa."
cover_credit_name: "Kelly Sikkema"
cover_credit_url: "https://unsplash.com/photos/workflow-diagram-product-brief-and-user-goals-are-shown-wdnpaTNwOEQ"
---

Existe um jeito confortável de construir agente de IA: pegue um modelo bom, escreva um system prompt grande, conecte meia dúzia de ferramentas, adicione alguns MCP servers, coloque skills em Markdown, injete histórico de conversa e chame isso de plataforma.

No começo funciona.

Funciona do mesmo jeito que uma classe base enorme funciona no começo. Ela resolve o caso feliz, impressiona no demo e parece economizar tempo porque tudo está em um lugar só. Depois vem a conta: contexto inchado, permissões abertas, custo imprevisível, comportamento difícil de depurar e um agente que precisa reler o mundo inteiro para executar uma tarefa pequena.

Esse é o problema que os **agentes de domínio específico** tentam resolver.

Eles partem de uma ideia antiga de engenharia de software: composição vence herança quando o sistema cresce. Em vez de criar um agente universal que herda ferramentas, instruções e responsabilidades de todos os domínios, você cria agentes menores, com fronteiras claras, e compõe esses agentes por meio de um coordenador.

Não é uma estética arquitetural. É uma forma de reduzir contexto, custo e superfície de erro.

## O agente inchado é a nova classe Deus

Todo time que constrói agentes acaba passando pela mesma tentação: adicionar só mais uma ferramenta.

Só mais uma integração com Gmail. Só mais uma consulta no CRM. Só mais uma skill para escrever relatório. Só mais um MCP server. Só mais uma regra no prompt. Só mais uma memória persistente. Só mais um trecho de histórico porque talvez seja útil.

O agente vai acumulando responsabilidade até virar uma classe Deus probabilística.

O problema não é que essas capacidades são inúteis. Muitas são necessárias. O problema é que elas ficam no mesmo espaço de execução. A tarefa "buscar o último email da Maria" viaja junto com ferramentas de GitHub, instruções de compliance, histórico de planejamento, documentos de produto, regras de escrita, comandos de shell e qualquer outra coisa que tenha sido colocada no contexto.

Isso cria três custos.

O primeiro é financeiro. Tokens irrelevantes continuam sendo tokens pagos.

O segundo é cognitivo. Quanto mais coisa o modelo vê, mais caminhos plausíveis ele pode inventar.

O terceiro é operacional. Quando algo dá errado, fica difícil descobrir se o erro veio da ferramenta, do prompt, da memória, da escolha do modelo, do histórico ou da interação entre tudo isso.

## Skill não é agente

Skills são úteis. Ferramentas são úteis. MCP é útil. O erro é achar que qualquer uma dessas coisas substitui uma unidade operacional completa.

Uma skill normalmente é instrução. Ela ensina o agente a fazer algo. Uma ferramenta executa uma operação. Um MCP server distribui ferramentas e recursos. Tudo isso ainda costuma cair dentro do mesmo agente, com o mesmo histórico, a mesma identidade, o mesmo orçamento e a mesma janela de contexto.

Um agente de domínio específico é outra coisa.

Ele tem objetivo próprio, prompt próprio, ferramentas próprias, permissões próprias, limites próprios, evals próprios e telemetria própria. Ele não é um arquivo de documentação dentro de um agente maior. Ele é um executor com contrato.

Um agente de Gmail, por exemplo, não deveria saber escalar Kubernetes. Um agente de cobrança não deveria conseguir editar um repositório. Um agente de revisão de PR não deveria aplicar crédito para cliente. Essa separação parece óbvia quando falamos de sistemas tradicionais, mas frequentemente desaparece quando colocamos um modelo no centro.

O modelo não deveria ser desculpa para jogar fora fronteiras de arquitetura.

## Composição muda a unidade de raciocínio

A diferença prática aparece no fluxo.

No desenho monolítico, o usuário pede:

> Encontre o último email da Maria e crie uma tarefa no Notion.

O agente principal recebe o pedido, relê o histórico, vê todas as ferramentas disponíveis, decide usar Gmail, depois Notion, talvez consulte outra coisa, talvez carregue instruções que não importam e segue.

No desenho composto, o coordenador divide o trabalho:

1. chama um agente de email com uma tarefa estreita;
2. recebe uma resposta estruturada;
3. chama um agente de Notion com outra tarefa estreita;
4. devolve o resultado para o usuário.

O detalhe importante é que o agente de email não precisa receber o mundo inteiro. Ele recebe o pedido específico, seu prompt de domínio e suas ferramentas. O agente de Notion também. O contexto deixa de ser um depósito global e vira insumo local.

Isso muda a economia do sistema.

O coordenador pode continuar usando um modelo mais forte para interpretar intenção, dividir trabalho e decidir quando parar. Os agentes de domínio podem usar modelos menores, prompts menores e ferramentas mais estreitas. Em muitos casos, eles não precisam ser brilhantes. Precisam ser consistentes dentro de uma tarefa bem desenhada.

Essa é a parte que muita discussão sobre agentes perde: nem toda inteligência precisa estar no mesmo lugar.

## O ganho de token é consequência, não objetivo

Justin Schroeder, da StandardAgents, defende que agentes de domínio específico podem trazer ganhos grandes de eficiência de tokens porque cada agente trabalha com um contexto muito menor. A ideia é intuitiva: se uma tarefa precisa apenas de Gmail, não faz sentido pagar para o modelo processar GitHub, Sheets, Slack, shell, histórico longo e regras que não participam daquela execução.

Mas eu não trataria economia de token como o único argumento.

O ganho principal é reduzir mistura.

Quando o contexto é menor, o comportamento tende a ficar mais legível. Quando a ferramenta é mais estreita, a falha fica mais contida. Quando a permissão é mais local, o acidente máximo diminui. Quando o agente tem evals próprios, você mede o domínio em vez de medir uma média confusa de tarefas diferentes.

Token é a métrica fácil de ver. Acoplamento é o problema mais profundo.

## Modelos menores ficam mais plausíveis

Existe uma crença implícita em muita arquitetura de agente: se o sistema é importante, use o modelo mais capaz para tudo.

Isso é confortável, mas caro.

Um modelo grande consegue compensar muita bagunça. Ele entende instrução ruim, navega contexto longo, escolhe ferramentas em meio ao ruído e se recupera de ambiguidade melhor do que modelos menores. Só que essa capacidade vira muleta arquitetural. Você paga por inteligência geral para resolver um problema que talvez fosse melhor tratado com fronteira melhor.

Agentes de domínio específico permitem outra estratégia: usar modelos menores em tarefas menores.

Um agente que só classifica tickets de suporte por uma taxonomia estável não precisa do mesmo modelo que coordena uma migração entre repositórios. Um agente que só transforma um evento interno em uma linha de planilha não precisa do mesmo raciocínio que um agente de investigação de incidente. Um agente que valida se uma resposta segue uma política pode ser pequeno, barato e repetível.

O ponto não é usar modelo pequeno por ideologia. É parar de usar modelo grande como substituto para desenho de sistema.

## Segurança aparece como efeito colateral bom

Agentes de domínio específico também melhoram segurança, mas não porque o prompt fica mais educado.

Eles melhoram segurança porque a fronteira de capacidade fica menor.

Um agente de cobrança pode ter permissão para consultar faturas e propor ajuste. Isso não implica permissão para apagar cliente, alterar feature flag, ler código-fonte ou falar com produção. Um agente de deploy pode ter permissão para operar um serviço específico, em uma região específica, com dry-run e aprovação. Isso não implica acesso amplo à conta cloud inteira.

Essa limitação precisa estar no harness, nas credenciais, nas APIs e no orquestrador. O prompt pode explicar a política, mas não pode ser a política.

Aqui a composição ajuda porque cada agente carrega uma identidade menor. Se tudo passa por um superagente com uma credencial enorme, você volta ao velho problema de permissão excessiva. Se cada domínio tem identidade, ferramentas e limites próprios, o erro continua possível, mas o raio do erro diminui.

Isso é engenharia de confiabilidade tanto quanto segurança.

## O coordenador não pode virar outro agente Deus

Existe uma armadilha óbvia: tirar tudo do agente principal e colocar tudo no coordenador.

Se o coordenador conhece todos os detalhes de todos os domínios, carrega todas as ferramentas, decide todas as políticas, reescreve todas as respostas e mantém todo o histórico, você só mudou o nome do monólito.

Um bom coordenador deveria fazer menos.

Ele precisa entender intenção, escolher agentes, passar contexto mínimo, combinar resultados, detectar falhas e saber quando pedir ajuda. Ele não deveria replicar a lógica interna de cada domínio. Também não deveria transformar cada resposta em uma conversa aberta entre agentes sem contrato.

Coordenação útil parece mais com roteamento, contrato e controle de execução do que com brainstorm entre modelos.

Isso exige catálogos de agentes, descrições claras de capacidade, schemas de entrada e saída, políticas de autorização e traces. Sem isso, "multi-agente" vira teatro: vários modelos falando, pouca engenharia acontecendo.

## Como desenhar um agente de domínio específico

Eu começaria com perguntas simples.

Qual é o domínio? Não "produtividade" ou "empresa". Isso é amplo demais. Domínio útil é algo como triagem de tickets, leitura de email, geração de proposta comercial, revisão de PR, consulta de inventário, resposta a incidentes ou validação de compliance.

Quais ações esse agente pode executar? Ler é diferente de escrever. Propor é diferente de aplicar. Simular é diferente de alterar estado.

Qual é o contrato de entrada? Se qualquer texto serve, o agente vira genérico rápido. Um bom domínio aceita linguagem natural, mas deveria conseguir transformá-la em uma intenção estruturada pequena.

Qual é o contrato de saída? Texto livre é bom para humanos, ruim para composição. Se outro agente depende do resultado, a saída precisa ter formato, evidência e estado.

Quais ferramentas são realmente necessárias? Ferramenta genérica demais é convite para improviso. Se o agente precisa criar ticket, dê `create_ticket`, não `call_http`.

Quais evals provam que ele funciona? Agente de domínio sem eval vira uma promessa. O mínimo é ter casos felizes, casos ambíguos, casos proibidos, falhas de ferramenta e regressões conhecidas.

Qual é o orçamento? Custo, latência, tool calls, retries, profundidade de loop e tamanho máximo de contexto precisam ser parte do contrato.

## A régua prática

Se eu fosse revisar uma arquitetura de agentes de domínio específico, usaria esta lista:

1. Cada agente tem um domínio que cabe em uma frase concreta?
2. As ferramentas são estreitas ou ainda existe uma ferramenta genérica poderosa demais?
3. As permissões vivem fora do prompt?
4. O coordenador passa contexto mínimo ou despeja o histórico inteiro?
5. A saída de cada agente é estruturada o suficiente para composição?
6. Existe isolamento de identidade, orçamento e telemetria por agente?
7. Há evals por domínio, não apenas um teste geral do sistema?
8. O sistema sabe o que fazer quando um subagente falha?
9. Humanos conseguem auditar qual agente decidiu e qual agente executou?
10. Adicionar um novo domínio exige acoplar tudo de novo ao agente principal?

A última pergunta é a mais importante.

Se cada novo domínio aumenta o prompt central, a lista central de ferramentas e a permissão central, você ainda está fazendo herança. Só colocou uma etiqueta de agentes em cima.

## O risco oposto existe

Nem todo problema precisa virar dez agentes.

Dividir cedo demais cria latência, custo de coordenação, contratos prematuros e uma superfície maior para falhas distribuídas. Às vezes um agente único com duas ferramentas estreitas é a arquitetura correta. Às vezes um workflow determinístico resolve melhor que qualquer agente. Às vezes uma função com validação forte é suficiente.

Agente de domínio específico não é desculpa para transformar todo if em organização multi-agente.

A divisão começa a valer quando existem fronteiras reais: permissões diferentes, ferramentas diferentes, evals diferentes, modelos diferentes, custos diferentes, ownership diferente ou necessidade de reuso por vários coordenadores.

Sem fronteira real, você está só adicionando rede a um problema local.

## O que muda

A mudança importante é parar de tratar o agente como unidade final do produto.

O produto real começa a parecer um sistema de agentes menores, ferramentas estreitas, políticas fora do prompt, memória operacional, evals por domínio e um coordenador que sabe compor sem absorver tudo.

Isso combina com a direção de meta harness, harness engineering e orquestração multi-agente. O agente isolado continua importante, mas deixa de ser o lugar onde toda complexidade mora.

O futuro próximo provavelmente não será um superagente com todas as skills do mundo. Será uma rede de agentes pequenos o suficiente para serem entendidos, baratos o suficiente para rodarem muito, limitados o suficiente para serem confiáveis e composáveis o suficiente para resolver tarefas maiores.

O agente genérico é bom para começar.

O agente de domínio específico é como você impede que o começo vire arquitetura permanente.

## Referências

- [The Future Is Domain-Specific Agents - Justin Schroeder, StandardAgents](https://www.youtube.com/watch?v=spNAUEgq_A8)
- [Resumo do episódio pela BigGo Finance](https://finance.biggo.com/podcast/340556ea84c18930)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
