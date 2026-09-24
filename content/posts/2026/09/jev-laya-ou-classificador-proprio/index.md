---
title: "Dissecando o hype das decisões tipadas: Jev, Laya ou classificador próprio"
description: "As tabelas colocam Jev e Laya como vencedores em recortes diferentes. A escolha depende de onde os rótulos são definidos e de quanto dado rotulado já existe."
date: "2026-09-28T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - reliability
    - developer-experience
    - cost-management
url: /jev-laya-ou-classificador-proprio/
cover: cover.jpg
cover_alt: "Gavetas de um catálogo de fichas de madeira com etiquetas."
cover_credit_name: "Daniel Brzdęk"
cover_credit_url: "https://unsplash.com/photos/vintage-wooden-card-catalog-drawers-with-labels-kAQo6CJCPN4"
---

Em setembro, três afirmações sobre o mesmo problema circularam ao mesmo tempo.

A TypeSafe lançou o Jev com números de 193,6x mais rápido e 444,6x mais barato que modelos de fronteira. A ConvAI publicou o Laya, com pesos Apache 2.0, e uma tabela em que o checkpoint especializado vence o número publicado do Jev no benchmark `typed-decisions` por 0,766 contra 0,727. A mesma tabela chama self-hosting de "$0", ou seja, sem cobrança por token. A máquina continua tendo custo.

Existe ainda uma opção mais velha que as duas: para classificar texto curto contra rótulos fixos, TF-IDF com regressão logística já fazia o trabalho antes de qualquer uma dessas empresas existir.

Os números medem recortes diferentes e não escolhem o que entra no pipeline.

**Eu escolho pela posição dos rótulos e pela quantidade de dado rotulado.** Se a taxonomia é estável e existem exemplos suficientes, começo por um classificador próprio. Jev e Laya entram quando perguntas e opções precisam mudar sem retreino.

## As ressalvas já estão nas próprias páginas de produto

O anúncio do Jev é mais modesto do que a repercussão sugere. Diogo Almeida diz que o modelo "alcança níveis de inteligência similares aos LLMs existentes em tarefas System One, sendo duas ordens de grandeza mais rápido e mais eficiente". O anúncio reivindica paridade de qualidade com menor custo e latência, sem dizer que o Jev julga melhor.

Debaixo dos gráficos, a própria TypeSafe escreveu seções chamadas "Nuance". Os 193,6x e 444,6x saem de quatro workflows construídos pelo time de capacidades da empresa. A resposta de referência é a média de dois modelos de fronteira, o que favorece respostas parecidas com as deles. Os testes de velocidade, em geral, rodam de laptops na costa oeste dos Estados Unidos.

A TypeSafe também diz que a taxa de zero erro de tipo "não é empírica". Ela vem da construção do decoder, não de uma amostra. Essa garantia protege o envelope; [não prova que a decisão está correta](/jev-garante-o-formato-nao-a-decisao/).

A tabela e a seção "Honest Limits" do card do Laya precisam ser lidas juntas. A primeira lista "Laya (routed) 0,766" contra "Jev 1.13.0 0,727" e fecha com "$0 self-hosted". Mais abaixo, o card registra que os checkpoints base marcam 0,362 e 0,342 no mesmo benchmark, abaixo dos 0,461 de sempre chutar a classe majoritária. A conclusão do próprio texto é direta: o Laya é "uma base rápida para especializar, não um motor de decisão zero-shot".

Os 0,766 pertencem ao `laya-typed-decisions`, treinado nos 1.200 casos do split de treino desse mesmo benchmark. O número do Jev é zero-shot e, como a ConvAI avisa em itálico, veio de outra publicação; a empresa não teve acesso à API da TypeSafe nessa comparação.

O ECE de 0,081 em outra linha da tabela também precisa de contexto. É o resultado pós-calibragem do Laya base. O ECE médio bruto era 0,466 e caiu depois do ajuste de uma temperatura por tipo de pergunta e número de opções em dados do domínio.

O 0,766 mostra que um especialista treinado no benchmark vence um generalista zero-shot naquele benchmark. Não sustenta a frase "Laya vence Jev".

A tabela de `typed-decisions` aponta em duas direções. O Laya especializado tem argmax melhor, 0,766 contra 0,727. O número publicado do Jev tem soft accuracy melhor, 0,580 contra 0,471, e ECE menor, 0,144 contra 0,213. Um escolhe a resposta final certa com mais frequência; o outro fica mais perto da distribuição de probabilidade do professor. A comparação continua indicativa porque os números do Jev vieram de outra publicação.

## O rótulo entra no request ou no treino

Num classificador supervisionado, os rótulos existem antes do treino. Um modelo para `billing`, `technical` e `sales` aprendeu essas três classes, e adicionar `fraud` significa rotular exemplos novos, treinar de novo e publicar outra versão do artefato.

Jev e Laya recebem a lista no request:

```python
questions = {
    "department": {
        "type": "choice",
        "instructions": "Qual time deve atender este chamado?",
        "criteria": {
            "billing": "faturas, pagamentos, reembolsos",
            "technical": "bugs, indisponibilidade, erros de sistema",
            "other": "todo o resto",
        },
    },
    "churn_risk": {
        "type": "noul",
        "instructions": "O cliente ameaça cancelar?",
    },
}
```

O mesmo checkpoint pode escolher entre departamentos nesta chamada e entre ferramentas na próxima. As descrições de cada opção entram no cálculo, o que dá ao modelo informação que um rótulo sozinho não carrega. Várias perguntas tipadas sobre o mesmo estado saem numa única passagem.

No Laya, isso funciona assim: cada opção recebe um token `[MASK]` próprio, o modelo pontua esses marcadores e aplica softmax dentro da pergunta. O espaço de resposta é construído na hora, sem retreino.

Esse mecanismo tem um limite concreto. As opções dividem um orçamento fixo no head: 192 tokens no checkpoint inglês e 256 no multilíngue. O próprio card atribui parte da queda no Banking77 aos poucos tokens disponíveis para cada rótulo. Nesse teste, o número publicado do Jev é 0,870 com 72 rótulos; o Laya marca 0,425 com 77 nas configurações padrão. A API do Jev aceita até 255 opções, embora a TypeSafe use duas etapas nas escolhas de cardinalidade mais alta.

| Abordagem | Onde os rótulos são definidos | Dado do domínio para começar | Como uma classe nova entra |
| --- | --- | --- | --- |
| Jev | No request | Não é obrigatório | Muda o request |
| Laya base | No request | Não é obrigatório | Muda o request |
| Laya com fine-tuning | No request, depois de treino no domínio | Necessário | Muda o request, dentro do que o checkpoint aprendeu a julgar |
| Classificador próprio | No treino | Necessário | Rotula, treina e publica outra versão |

Um classificador com head fixo não aceita uma taxonomia arbitrária no request. Ele troca essa flexibilidade por especialização.

## Medi as três abordagens no mesmo conjunto privado

Comparei Jev, Laya base e um classificador treinado do zero num conjunto privado de 50 linhas de log, com seis categorias fixas e uma decisão binária de encaminhar ou não para revisão humana. As duas metades da decisão binária tinham 25 exemplos cada. Uma pessoa rotulou linhas de um único ambiente. Não publico o conteúdo, mas publico o protocolo e os limites.

O classificador usou n-grams de palavras de 1 a 2 e n-grams de caracteres com fronteira de palavra de 3 a 5, com TF-IDF, mais duas regressões logísticas balanceadas com `C=4.0` e threshold em 0,5, uma para a categoria e outra para a revisão. Avaliei por leave-one-out: para cada mensagem, o pipeline aprendeu vocabulário e pesos nas outras 49. Jev e Laya receberam a descrição das seis categorias e da pergunta binária, sem nenhum treino nesses exemplos.

Não coloquei o `laya-typed-decisions` nessa tabela. Ele foi especializado em outros quatro workflows, não nessas seis categorias; tratá-lo como o Laya ajustado para esta tarefa seria enganoso.

| Abordagem | Categoria | Revisão | As duas corretas |
| --- | ---: | ---: | ---: |
| Jev 1.13, zero-shot | 50/50 (100%) | 49/50 (98%) | 49/50 (98%) |
| Laya base, zero-shot | 44/50 (88%) | 45/50 (90%) | 40/50 (80%) |
| TF-IDF + regressão logística, leave-one-out | 43/50 (86%) | 23/50 (46%) | 19/50 (38%) |

Regras manuais acertaram as duas respostas em 47 das 50 linhas, mas eu as escrevi depois de ver o conjunto. Por isso elas não entram como concorrente cego na tabela. O resultado ainda mostra que uma parte grande da tarefa podia ser codificada sem modelo.

A linha de baixo foi a surpresa. A taxonomia era fixa, o cenário favorável ao classificador. Ele achou a origem da mensagem em 43 dos 50 casos, mas acertou 23 de 50 na decisão binária. O valor esperado por um chute aleatório nesse conjunto balanceado era 25. Os erros sugerem que 49 exemplos por fold não cobriam linguagem suficiente para distinguir uma palavra no texto do estado final descrito pela mensagem.

A taxonomia encaixava no classificador. Os 49 exemplos ainda não cobriam a decisão.

### O dado sintético mudou o resultado, não o tamanho do teste

Para testar se o problema era cobertura, gerei 1.200 linhas sintéticas: 100 para cada combinação entre as seis categorias e os dois resultados de revisão. Usei uma gramática determinística de famílias de eventos, com identificadores fictícios e sem enviar as mensagens reais para outro modelo. As linhas sintéticas entraram apenas no treino. As 50 reais continuaram sendo o teste.

A primeira versão do gerador chegou a 94% tanto em categoria quanto em revisão. A auditoria de sobreposição encontrou uma linha sintética quase igual a uma linha real, com Jaccard de tokens em 0,73. O número media vazamento. Rejeitei cópias exatas e qualquer linha acima de 0,55, regenerei o conjunto e rodei tudo outra vez.

| Treino do classificador | Categoria nas 50 reais | Revisão nas 50 reais | As duas corretas |
| --- | ---: | ---: | ---: |
| 49 reais por fold | 43/50 (86%) | 23/50 (46%) | 19/50 (38%) |
| 1.200 sintéticas | 42/50 (84%) | 46/50 (92%) | 40/50 (80%) |
| 1.200 sintéticas + 49 reais por fold | 45/50 (90%) | 42/50 (84%) | 37/50 (74%) |

As linhas sintéticas elevaram a decisão binária de 46% para 92%. Treinar só nelas chegou aos mesmos 40 acertos completos em 50 do Laya base, mas os orçamentos de informação não são comparáveis: eu escrevi a gramática depois de conhecer o teste. Misturar os 49 exemplos reais elevou a categoria para 90%, mas reduziu a revisão e o resultado conjunto.

Variando só o tamanho do treino sintético, dá para ver onde a curva vira.

| Linhas no treino | Revisão nas 50 reais |
| --- | ---: |
| 50 | 37/50 (74%) |
| 100 | 41/50 (82%) |
| 200 | 42/50 (84%) |
| 400 | 45/50 (90%) |
| 800 | 47/50 (94%) |
| 1.200 | 46/50 (92%) |

O método nunca foi o gargalo. A mesma pipeline de TF-IDF e regressão logística chega a 94% quando tem cerca de 800 exemplos rotulados. Com 49, fica no acaso.

O teste continua com 50 linhas. O intervalo de Wilson de 95% para 40 acertos vai de 67% a 89%; para os 49 acertos do Jev, vai de 90% a 100%. Todas as taxas dessa tabela carregam a incerteza de uma amostra pequena. Também desenhei a gramática depois de inspecionar o conjunto real, e esse conjunto já tinha orientado escolhas do protocolo. O experimento mostra que cobertura sintética pode treinar um classificador útil. Um holdout real novo, separado por tempo ou incidente, precisa medir a generalização.

O Laya base acertou 88% da categoria e 90% da revisão nesse conjunto, bem acima dos 0,362 do `typed-decisions`. A tarefa aqui é mais simples, com seis opções curtas em vez de perguntas encadeadas, e cabe no orçamento de tokens do head. Um resultado perto do acaso num benchmark não torna o modelo inútil em outra tarefa.

Num segundo conjunto de oito casos de estresse, escritos separadamente, o Jev acertou as duas perguntas em sete e o Laya base em cinco. O classificador treinado nas 50 linhas reais acertou cinco; o treinado nas 1.200 sintéticas, seis. Oito exemplos não sustentam um ranking.

Não rodei grid search nem usei embeddings pré-treinados. As linhas do classificador medem um baseline pré-definido, não o teto de supervised learning. Leave-one-out reaproveita o mesmo conjunto em 50 folds e não substitui um teste coletado depois. O orçamento de informação também difere: os modelos receberam descrições das opções; a regressão recebeu exemplos rotulados ou uma gramática escrita por quem conhecia a tarefa. Esta é uma checagem de engenharia com 50 linhas, não um benchmark público.

Sobre latência e custo eu fico com o que medi. O p50 do Jev foi de 0,37 s e o p95 de 0,76 s, com requests enviados do Brasil. A mediana ficou dentro da faixa de 70 a 500 ms anunciada pela TypeSafe para medições feitas na costa oeste; o p95 passou dela. Terceiros citados pela ConvAI mediram 236 a 276 ms de p50. As 50 decisões consumiram 27.987 tokens de input e custaram US$ 0,0012, o que coloca um milhão de mensagens desse tamanho em cerca de US$ 24. Um serviço hospedado, um modelo local e uma regressão em CPU medem trabalhos diferentes.

## Jev, quando ainda não existe dado rotulado

O Jev é a opção mais direta no começo, quando não há dataset e as perguntas cabem em `choice`, `score` e `noul`. A aplicação descreve os critérios, recebe valores tipados com probabilidade e o time não hospeda pesos. No meu conjunto ele também foi o mais preciso, sem ter visto um único exemplo.

Eu usaria essa vantagem para começar em shadow mode: o modelo decide, o sistema não executa, e as decisões humanas viram o primeiro conjunto rotulado que você vai precisar de qualquer jeito.

Eu manteria o Jev quando o conjunto de opções muda com frequência ou várias perguntas usam o mesmo estado. Ele também evita o limite de tokens do Laya em escolhas com muitas opções. No começo do projeto, chegar ao primeiro resultado pode pesar mais do que operar um modelo.

O que você não controla: os pesos e a arquitetura são fechados, e fine-tuning pelo cliente não faz parte da oferta publicada. Sobram perguntas, critérios e thresholds. Para muita gente isso é suficiente; para quem tem requisito de self-hosting, é bloqueante.

## Fine-tuning do Laya, quando o domínio é específico e as opções ainda mudam

O `laya-typed-decisions` parte do checkpoint base de 421 milhões de parâmetros e usa RLCD, REINFORCE e cross-entropy contra as distribuições do professor. O card diz que o checkpoint treinou no split de 1.200 casos, com 6.000 decisões. O notebook atual configura quatro épocas depois de separar uma fatia para calibragem. Depois do treino, as opções continuam chegando no request. Esse é o ganho técnico sobre um classificador de head fixo: o modelo aprende a julgar exemplos do domínio sem congelar uma lista de classes.

Eu pagaria esse custo quando as três condições aparecem juntas: o domínio tem padrões que o modelo base não conhece, as perguntas ou opções variam entre requests, e self-hosting ou controle do treino são requisitos. Sem esse conjunto, eu testaria Jev ou um classificador menor primeiro.

O custo de reprodução não está claro. O notebook oficial exige duas T4 no Kaggle. O card do modelo estima "cerca de 4 a 5 horas". A seção 5 do próprio notebook diz "~4 to 6 minutes total". O arquivo publicado não tem nenhuma célula com output de execução, então não dá para saber qual das duas está certa sem rodar. Eu trataria a duração como não verificada.

O checkpoint continua preso ao domínio do treino. O card diz que ele foi ajustado em quatro workflows sintéticos e deve se comportar como o base, "ou pior", em qualquer outra coisa. Eu também não trataria a confiança publicada como calibrada. As temperaturas por tipo foram ajustadas numa fatia dos mesmos itens de treino, e o próprio card recomenda refazer o ajuste com dados held-out do domínio.

Se as suas classes são seis filas fixas, esse fine-tuning mantém uma capacidade que a aplicação nunca vai exercer.

## Classificador próprio, quando a taxonomia é estável e existe dado

Com taxonomia estável, cada exemplo novo alimenta exatamente o artefato que vai para produção. Dá para separar treino, validação e teste por tempo, origem e cliente. Dá para medir falso positivo por classe em vez de olhar só uma média. E o modelo tem ordens de grandeza menos parâmetros do que 421 milhões.

Meus 50 exemplos eram uma amostra. O treino sintético ampliou a cobertura dos eventos, mas não trouxe evidência independente. Linhas reais novas, rotuladas e separadas no tempo, dirão se TF-IDF é só o baseline ou já resolve a tarefa.

Eu começaria pequeno e subiria só quando parasse de melhorar: TF-IDF com regressão logística ou SVM linear, depois embeddings congelados com um head linear, depois SetFit ou fine-tuning do encoder. Essa ordem mostra quanto da tarefa depende de vocabulário, de semântica geral ou de adaptação do encoder. Pular direto para o passo três esconde qual camada produziu o ganho.

Probabilidade pede validação à parte, em qualquer uma das quatro abordagens. Acurácia não garante calibração. Temperature scaling, como em Guo et al., é um ajuste simples, mas a temperatura precisa ser aprendida num conjunto que não treinou o modelo. O card do Laya especializado documenta que o checkpoint publicado não fez essa separação. Vale o mesmo para threshold: se mensagens quase duplicadas atravessarem treino e teste, o número mede memorização de template. Em logs, tickets e alertas, dividir por tempo ou por incidente costuma ser mais honesto do que embaralhar linhas.

## A decisão cabe numa tabela

| Situação | Primeira escolha |
| --- | --- |
| Classes estáveis, exemplos rotulados suficientes e resultado validado num holdout | Classificador próprio |
| Classes estáveis e poucos exemplos | Jev como baseline, com regras e classificador simples em paralelo |
| Opções mudam por request e uma API externa é aceitável | Jev |
| Opções mudam por request e self-hosting é requisito | Laya base |
| Opções mudam, o domínio é específico e há dado para treino | Laya com fine-tuning |
| Dezenas de opções na mesma pergunta | Jev; no Laya, aumentar `head_max_len` ou usar `choice` hierárquico |
| A regra pode ser calculada sem ambiguidade | Código determinístico |

A tabela não escolhe threshold nem precifica erro. Uma classificação errada que só reorganiza uma fila não tem o mesmo orçamento de risco que uma decisão sobre acesso ou dinheiro.

Antes de automatizar qualquer uma delas, eu compararia as quatro no mesmo conjunto congelado, medindo precisão e recall por classe, calibração por faixa de confiança, custo fim a fim e taxa de envio para revisão humana. Para Jev e Laya, mesmo `state`, mesmas descrições, mesmas opções. Para o classificador, vocabulário e hiperparâmetros proibidos de olhar o teste. E [a eval continua depois desse primeiro teste](/avaliando-agentes-de-ia-alem-do-vibes-check/), com regressão no CI e sinal do comportamento em produção.

> Os rótulos precisam mudar a cada request, ou só quando o produto muda?

## Fontes

- [Introducing System One Models and Jev, TypeSafe](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [Jev garante o formato. Não garante a decisão](/jev-garante-o-formato-nao-a-decisao/)
- [Laya no Hugging Face](https://huggingface.co/convaiinnovations/laya)
- [Laya Typed-Decisions no Hugging Face](https://huggingface.co/convaiinnovations/laya-typed-decisions)
- [Notebook de fine-tuning em 2x T4](https://github.com/NandhaKishorM/laya/blob/main/notebooks/laya_finetune_typed_decisions_2xT4_kaggle.ipynb)
- [Dataset `typed-decisions`](https://huggingface.co/datasets/LocalLLaMA/typed-decisions)
- [Classificação de texto com features esparsas, scikit-learn](https://scikit-learn.org/stable/auto_examples/text/plot_document_classification_20newsgroups.html)
- [Efficient Few-Shot Learning Without Prompts, Tunstall et al.](https://arxiv.org/abs/2209.11055)
- [On Calibration of Modern Neural Networks, Guo et al.](https://proceedings.mlr.press/v70/guo17a.html)
- [Laya tem pesos abertos. A operação fica com você](/laya-decisoes-tipadas-com-pesos-abertos/)
