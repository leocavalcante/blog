---
title: "GPT-5.6 Luna: o modelo que virou meu padrão no Codex"
description: "Depois de quase 10 bilhões de tokens no Codex, por que o GPT-5.6 Luna virou meu modelo padrão: custo, desempenho, contexto e limites."
date: "2026-08-26T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - codex
    - llm
    - agent
    - developer-experience
    - cost-management
url: /gpt-5-6-luna-o-modelo-que-virou-meu-padrao-no-codex/
cover: cover.jpg
cover_alt: "Paisagem noturna sob a luz da lua, com um rastro de luz atravessando as montanhas."
cover_credit_name: "Jonathan Barreto"
cover_credit_url: "https://unsplash.com/photos/landscape-photography-of-green-trees-under-moon-EkjHd-r_jF0"
---

Há modelos que impressionam na primeira resposta. E há modelos que mudam o jeito como você trabalha depois de semanas de uso.

Para mim, o GPT-5.6 Luna entrou na segunda categoria.

No último mês, usei o Luna com o Codex de forma extensiva, chegando a quase 10 bilhões de tokens. Esse número não é um benchmark controlado e não deve ser lido como uma medição universal de produtividade. É apenas a quantidade de trabalho que acabou passando por esse modelo no meu fluxo.

Ainda assim, depois de tantas tarefas, testes, correções e revisões, minha conclusão ficou clara: hoje, Luna é meu modelo padrão.

Não porque ele seja o modelo mais inteligente em qualquer tarefa. Não é. Sol continua sendo a escolha para os problemas mais difíceis, e Terra pode ser um meio-termo melhor em alguns cenários. O que torna Luna especial é outra coisa: ele entrega inteligência suficiente, velocidade suficiente e custo baixo o bastante para continuar trabalhando.

## O nome esconde a decisão importante

GPT-5.6 não é uma única capacidade. A família tem três níveis com papéis diferentes: Sol é o modelo de fronteira, Terra tenta equilibrar inteligência e custo, e Luna foi desenhado para trabalho rápido, repetível e de alto volume.

A própria [documentação do modelo](https://developers.openai.com/api/docs/models/gpt-5.6-luna) compara Luna ao nível nano das famílias GPT-5 anteriores. Isso não significa que ele seja apenas um modelo pequeno com menos parâmetros visíveis. Significa que a decisão de projeto prioriza a quantidade de trabalho útil que pode ser realizada por unidade de custo.

As características mais importantes são:

| Característica | GPT-5.6 Luna |
| --- | --- |
| Janela de contexto na API | 1,05 milhão de tokens |
| Saída máxima | 128 mil tokens |
| Esforço de raciocínio | `none`, `low`, `medium`, `high`, `xhigh` e `max` |
| Entrada e saída | Texto; imagem como entrada |
| Data de corte do conhecimento | 16 de fevereiro de 2026 |
| Fine-tuning | Não suportado |

Na Responses API, a página também lista function calling, structured outputs, web search, file search, code interpreter, hosted shell, apply patch, skills, computer use, MCP e tool search. No Codex, isso é mais importante do que uma lista de capacidades isoladas: o modelo precisa ler um repositório, escolher uma ação, executar uma ferramenta, interpretar o resultado e continuar.

## O preço muda a experiência, não apenas a fatura

No lançamento, Luna custava US$ 1 por milhão de tokens de entrada e US$ 6 por milhão de tokens de saída. Em 30 de julho, a OpenAI reduziu o preço em 80%. A tabela atual da API ficou assim:

| Modelo | Entrada | Entrada em cache | Saída |
| --- | ---: | ---: | ---: |
| GPT-5.6 Luna | US$ 0,20 | US$ 0,02 | US$ 1,20 |
| GPT-5.6 Terra | US$ 2,00 | US$ 0,20 | US$ 12,00 |
| GPT-5.6 Sol | US$ 4,00 | US$ 0,40 | US$ 20,00 |

Os valores são por milhão de tokens e correspondem à tabela atual da [página de comparação da OpenAI](https://developers.openai.com/api/docs/models/compare). Há uma ressalva importante: requisições com mais de 272 mil tokens de entrada entram em uma faixa de contexto longo, com multiplicadores diferentes. O custo real depende também do mix entre entrada, saída, cache, ferramentas e modalidade de processamento.

Para dar uma ordem de grandeza, se os meus quase 10 bilhões de tokens fossem cobrados diretamente pela API:

- 10 bilhões de tokens somente de entrada não armazenada em cache custariam cerca de US$ 2.000;
- 10 bilhões somente de saída custariam cerca de US$ 12.000;
- 10 bilhões de entrada em cache custariam cerca de US$ 200.

Isso não é uma estimativa da minha fatura. Uso o Luna dentro do Codex, e o consumo de uma assinatura não é a mesma coisa que uma conta da API. A própria OpenAI informou que os preços de assinatura e os orçamentos de cota não mudaram, mas que Terra e Luna passaram a consumir menos créditos. Sem separar entrada, saída, cache e regras do plano, transformar "10 bilhões de tokens" em dinheiro seria apenas chute.

Mesmo assim, o efeito prático do preço é enorme. Um agente de código não faz uma chamada e termina. Ele lê arquivos, procura referências, roda testes, recebe erros, corrige, roda tudo de novo e revisa o próprio diff. Quando cada iteração custa pouco, fica viável deixar o agente investigar mais uma hipótese ou executar mais uma verificação.

O valor não está somente no preço por token. Está na redução da fricção para tentar, medir e tentar de novo.

## O que os benchmarks dizem

Os números publicados pela OpenAI contam uma história mais interessante do que "Luna é o melhor modelo". Em algumas avaliações, ele supera o GPT-5.5. Em outras, fica ligeiramente abaixo. O padrão é de proximidade suficiente para tornar o preço decisivo em muitos fluxos.

| Avaliação | GPT-5.6 Luna | GPT-5.5 | Leitura rápida |
| --- | ---: | ---: | --- |
| Agents' Last Exam | 50,3% | 46,9% | Acima do GPT-5.5 |
| GDPval-AA v2 | 1.591,8 Elo | 1.493,7 Elo | Acima do GPT-5.5 |
| SWE-Bench Pro | 62,7% | 59,4% | Acima do GPT-5.5 |
| DeepSWE v1.1 | 67,2% | 67,0% | Praticamente empatado |
| Terminal-Bench 2.1 | 84,7% | 85,6% | Muito próximo |
| Artificial Analysis Coding Agent Index | 74,6 | 76,4 | Abaixo, mas competitivo |
| BrowseComp | 83,3% | 84,4% | Muito próximo |

Esses resultados vêm da [tabela de avaliações do lançamento do GPT-5.6](https://openai.com/index/gpt-5-6/). Como sempre, são resultados publicados pelo fornecedor, com harnesses e configurações específicas. Eles servem para formular hipóteses, não para dispensar uma avaliação no seu próprio trabalho.

O [guia para builders da OpenAI](https://openai.com/index/builders-guide-to-gpt-5-6/) traz uma comparação de custo ainda mais expressiva. No lançamento, Luna com esforço Extra High marcou 84,04% no BrowseComp por US$ 1,33, enquanto GPT-5.5 no mesmo benchmark marcou 84,36% por US$ 33,27. A diferença de qualidade era pequena; a diferença de custo, não.

A conclusão que eu tiro não é que Luna venceu Sol. É que, em uma parte relevante do trabalho, a diferença entre eles é pequena o bastante para que várias tentativas baratas sejam melhores do que uma única tentativa cara.

## Por que ele funciona tão bem no Codex

O Codex muda a unidade de trabalho. Em um chat, avalio principalmente a qualidade da resposta. Em um agente de código, preciso avaliar se ele consegue transformar uma intenção em uma alteração verificável.

É aí que Luna ganhou espaço no meu fluxo.

### 1. O custo reduz a fricção

A maior vantagem não é uma resposta espetacular. É poder pedir uma investigação, deixar o agente consultar o código, rodar um teste e fazer uma segunda passagem sem tratar cada chamada como um evento caro.

Para tarefas rotineiras, a capacidade de continuar importa tanto quanto a qualidade da primeira tentativa. Um agente que pode testar mais uma hipótese tende a ser mais útil do que um modelo teoricamente melhor que precisa ser interrompido por causa do orçamento.

### 2. Ele é forte onde o trabalho é bem definido

Luna faz mais sentido quando o objetivo, o escopo e a definição de pronto estão claros: localizar uma implementação, adicionar testes, corrigir uma regressão, atualizar uma dependência, fazer uma refatoração delimitada, revisar documentação ou transformar um conjunto de resultados em um resumo.

Essas tarefas ainda exigem julgamento, mas não precisam que o modelo invente o problema inteiro. O repositório, os testes e os critérios de aceitação fornecem parte do raciocínio.

### 3. O harness carrega parte da inteligência

É tentador comparar modelos como se fossem apenas caixas de texto. No Codex, o resultado depende também de contexto, ferramentas, permissões, skills, memória, compactação, instruções do repositório e qualidade dos testes.

O [guia oficial de modelos](https://developers.openai.com/api/docs/guides/latest-model) recomenda usar Luna em fluxos eficientes e de alto volume. A [documentação de subagentes do Codex](https://learn.chatgpt.com/docs/agent-configuration/subagents) é ainda mais específica: Luna é indicada para agentes rápidos, bem delimitados, repetíveis ou de alto volume.

Esse é o argumento que desenvolvi no meu [post anterior, "Meta Harness: a camada que falta na engenharia de agentes"](/meta-harness-a-camada-que-falta-na-engenharia-de-agentes/). Um harness bem feito faz o Luna render melhor porque organiza o contexto, limita o escopo, dá ferramentas para agir e exige verificações antes de aceitar uma mudança. O modelo não fica mais inteligente no sentido estrito, mas consegue aplicar melhor a capacidade que já tem.

Isso combina com a forma como gosto de trabalhar. Deixo o modelo fazer exploração e execução mecânica, mas mantenho explícitos os limites, os comandos de validação e o resultado esperado.

### 4. A qualidade aparece no custo por mudança aceita

O número que me interessa não é quantos tokens o modelo consegue gerar. É quanto custa chegar a uma mudança que passou pelos testes, pode ser revisada e merece continuar existindo.

Se Luna entrega uma alteração correta em quatro iterações baratas, ele pode ser mais útil do que um modelo mais forte que chega perto em uma tentativa, mas consome o orçamento inteiro quando precisa corrigir a primeira interpretação.

Essa é a razão pela qual quase 10 bilhões de tokens são relevantes para a minha avaliação. Não é porque volume prova qualidade. É porque um modelo só vira ferramenta principal quando o custo permite que ele participe de quase todas as etapas do trabalho.

## Como escolher o esforço de raciocínio

Luna não é uma configuração única. O parâmetro de esforço muda a quantidade de trabalho que o modelo faz, e também muda latência e consumo.

Minha regra prática seria:

1. Use `low` quando a tarefa for direta e a velocidade for o fator principal.
2. Comece com `medium` para trabalho normal e como ponto de comparação.
3. Use `high` ou `xhigh` quando houver lógica complexa, hipóteses a verificar ou casos de borda.
4. Reserve `max` para tarefas em que uma exploração mais longa possa alterar materialmente o resultado.

Mais raciocínio não transforma uma especificação ruim em uma especificação boa. Se o agente não sabe qual arquivo pode alterar, qual teste prova a correção ou qual comportamento não deve mudar, aumentar o esforço pode apenas produzir uma investigação mais longa.

O mesmo vale para subagentes. O [Codex informa](https://learn.chatgpt.com/docs/agent-configuration/subagents) que, quando o modelo ou o esforço não são configurados, o subagente herda os valores do agente pai. Se a intenção é economizar usando Luna em um trabalhador, essa intenção precisa estar explícita e deve ser verificada no resultado. Um nome como "worker barato" não garante que o processo realmente usou Luna.

## A janela de contexto não é memória perfeita

1,05 milhão de tokens é uma capacidade impressionante, mas uma janela grande não garante que todas as informações terão a mesma relevância ou serão recuperadas corretamente.

Na mesma tabela oficial, Luna marcou 41,3% no MRCR v2 de oito agulhas entre 256 mil e 512 mil tokens e também 41,3% entre 512 mil e 1 milhão. O GPT-5.5 marcou 81,5% e 74% nesses dois intervalos. Esse benchmark mede uma forma específica de recuperação em contexto longo, não toda a experiência de programação, mas é um bom lembrete: colocar mais texto na conversa não é o mesmo que dar mais entendimento ao agente.

Existe ainda uma diferença entre a especificação da API e o ambiente do Codex. As notas do [Codex CLI 0.144.6](https://learn.chatgpt.com/docs/changelog) registraram a correção das janelas de contexto dos modelos GPT-5.6 para 272 mil tokens. O cliente, o canal de autenticação e as regras de compactação podem evoluir, portanto o valor mostrado pela sessão e o momento em que ela compacta são mais importantes para o trabalho real do que repetir o número da página da API.

Minha prática é não despejar o repositório inteiro no contexto só porque posso. Prefiro manter instruções curtas, dividir investigações, resumir resultados e devolver ao agente principal apenas o que muda uma decisão. Contexto é recurso de trabalho, não um depósito infinito.

## Onde eu não escolheria Luna

Ser o meu padrão não significa ser o modelo certo para tudo.

Eu escolheria Terra ou Sol quando a tarefa tiver muita ambiguidade, envolver uma decisão arquitetural, exigir investigação de segurança, depender de uma síntese delicada ou tiver um custo alto de erro. Também não usaria Luna como substituto de revisão humana em mudanças irreversíveis ou em decisões de produto.

Há limites objetivos: a página do modelo não lista áudio ou vídeo como modalidades e não oferece fine-tuning. A janela longa exige cuidado. E workflows com muitos subagentes consomem mais tokens, porque cada agente faz seu próprio trabalho de modelo e de ferramentas.

Também há relatos de experiências diferentes da minha. Em uma [discussão da comunidade](https://www.reddit.com/r/hermesagent/comments/1uvk24n/thoughts_after_using_gpt_56_luna_for_48_hours/), um usuário descreveu Luna como inteligente, mas lento em esforço alto, com tendência a fazer várias iterações pequenas e ocasionalmente ignorar instruções explícitas. É um relato anedótico, não uma medição geral. Ainda assim, ele aponta para um risco real: custo baixo não elimina a necessidade de observar loops, instruções esquecidas e contexto degradado.

O modelo também não é o sistema inteiro. Um [trabalho recente sobre harness scaling](https://arxiv.org/abs/2608.15089) relatou elevar o resultado de GPT-5.6 Luna de 76,7% para 85,4% no Terminal-Bench 2.1 usando um runtime e um runbook persistente. A comparação não é um resultado oficial do leaderboard e não é diretamente equivalente aos números da OpenAI, mas reforça uma ideia importante: o modelo é apenas uma parte da performance.

## O que eu aprendi depois de 10 bilhões de tokens

A primeira lição é que preço é uma capacidade operacional. Quando o custo permite rodar mais ciclos de leitura, execução e verificação, ele muda o que vale a pena delegar.

A segunda é que "modelo padrão" não precisa significar "modelo único". Luna pode ser a base do fluxo, enquanto Terra ou Sol entram quando o problema ultrapassa o limite de ambiguidade, risco ou profundidade que o custo otimizado consegue tratar bem.

A terceira é que o melhor benchmark é a mudança aceita por unidade de custo. Leaderboards ajudam a escolher o que testar. Eles não dizem qual modelo entende melhor o seu repositório, suas convenções, seus testes e seu nível de tolerância a retrabalho.

Por isso, hoje eu escolho GPT-5.6 Luna com bastante confiança para o trabalho cotidiano no Codex. Ele não é sempre o mais brilhante da sala. É o colega que consigo chamar para quase tudo, que trabalha rápido, custa pouco e ainda entrega resultados bons o bastante para merecer uma revisão séria.

Para mim, esse equilíbrio é mais valioso do que uma demonstração isolada de capacidade. A inteligência mais útil é aquela que você consegue manter trabalhando.

## Fontes

- [GPT-5.6: Frontier intelligence that scales with your ambition](https://openai.com/index/gpt-5-6/)
- [Advancing the price-performance frontier with GPT-5.6](https://openai.com/index/advancing-the-price-performance-frontier-with-gpt-5-6/)
- [GPT-5.6 Luna Model](https://developers.openai.com/api/docs/models/gpt-5.6-luna)
- [Compare models](https://developers.openai.com/api/docs/models/compare)
- [Model guidance for GPT-5.6](https://developers.openai.com/api/docs/guides/latest-model)
- [The builder's guide to GPT-5.6](https://openai.com/index/builders-guide-to-gpt-5-6/)
- [Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [ChatGPT and Codex changelog](https://learn.chatgpt.com/docs/changelog)
- [StateM: Reaching 95.3% Raw Accuracy on Terminal-Bench 2.1 via Harness Scaling](https://arxiv.org/abs/2608.15089)
- [GPT-5.6 Luna benchmark review](https://layerlens.ai/blog/gpt-5-6-benchmark-review-sol-terra-luna)
- [Community discussion about using GPT-5.6 Luna](https://www.reddit.com/r/hermesagent/comments/1uvk24n/thoughts_after_using_gpt_56_luna_for_48_hours/)
