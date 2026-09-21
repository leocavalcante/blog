---
title: "Jev garante o formato. Não garante a decisão"
description: "Jev troca geração de texto por decisões tipadas com probabilidades. A proposta funciona quando o espaço de resposta é fechado, a pergunta é estreita e o código continua no controle."
date: "2026-09-21T13:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - reliability
    - developer-experience
    - cost-management
url: /jev-garante-o-formato-nao-a-decisao/
cover: cover.jpg
cover_alt: "Antiga cabine de sinalização ferroviária ao lado dos trilhos."
cover_credit_name: "Joseph Malone"
cover_credit_url: "https://unsplash.com/photos/old-railway-signal-box-beside-tracks-H3nVhaPXCc0"
---

A maioria das APIs de IA entrega texto. O software recebe a resposta, tenta extrair um JSON, valida os campos e decide se pode confiar no que sobrou.

O Jev começa de outro contrato. O código define as respostas possíveis antes da chamada. O modelo recebe um estado, avalia perguntas e devolve escolhas, scores ou probabilidades dentro daquele formato.

Não serve para escrever o email ao cliente. Pode decidir para qual fila o pedido vai. Não calcula se uma fatura venceu há 30 dias. Pode avaliar se a mensagem demonstra urgência.

**Jev cabe em pontos de decisão estreitos, repetidos e com saída fechada. Fora desse formato, código determinístico, um modelo generativo ou uma pessoa continuam sendo escolhas melhores.**

Essa fronteira é mais útil que qualquer promessa de velocidade.

## Jev é um modelo de decisão

A TypeSafe lançou o Jev em setembro de 2026 como o primeiro System One Model da empresa. O nome vem da distinção de Daniel Kahneman entre julgamento rápido e raciocínio deliberado.

O produto leva essa distinção para a API. Em vez de pedir uma resposta em texto, a aplicação envia dois elementos:

- `state`, com o conteúdo ou estado da aplicação que será avaliado;
- `questions`, com as decisões permitidas e os critérios de cada uma.

O modelo avalia todas as perguntas em paralelo. Cada resposta volta sob o mesmo identificador definido pela aplicação.

```json
{
  "model": "jev-latest",
  "state": {
    "message": "My payouts have been failing for three days."
  },
  "questions": {
    "department": {
      "type": "choice",
      "instructions": "Which team should handle `message`?",
      "criteria": {
        "billing": "Payments, invoices, or refunds",
        "technical": "Bugs, outages, or integrations",
        "sales": "Pricing, upgrades, or new accounts"
      }
    },
    "urgent": {
      "type": "noul",
      "instructions": "Does `message` require urgent attention?"
    }
  }
}
```

Nesse exemplo, `department` só pode receber uma das três opções. `urgent` volta como um número entre 0 e 1. Não há campo para o modelo redigir justificativa, inventar um quarto departamento ou devolver um parágrafo no lugar da resposta.

A API direta da TypeSafe usa `POST /v1/systemone`. O Jev também está disponível pela Decisions API da OpenRouter e pelo `evaluate` experimental do Vercel AI Gateway. Não é um endpoint de chat compatível com OpenAI. A forma da requisição faz parte do produto.

## Os três tipos cobrem problemas diferentes

O Jev expõe três primitivas.

`Choice` seleciona uma opção de um conjunto definido pela aplicação, com limite de 255 alternativas. A resposta inclui a opção escolhida, a distribuição de probabilidade entre todas elas e um valor de confiança.

`Score` posiciona o estado numa régua ordenada de até dez níveis. Um time pode descrever níveis como "sem risco", "requer revisão" e "bloquear". A resposta inclui a distribuição entre os níveis e um score ponderado.

`Noul` avalia uma afirmação binária e devolve a probabilidade de "sim". Uma saída `0.82` não é um booleano pronto. O código ainda decide se `0.82` basta para agir, pedir confirmação ou enviar o caso para review.

Esses tipos parecem simples porque foram desenhados para decisões simples. Tentar reconstruir geração de texto com centenas de `Choice` transforma a ferramenta no modelo errado para o trabalho.

## Type-safe descreve o envelope, não a verdade

A TypeSafe afirma que o Jev não comete erros de tipo. Essa garantia é verificável: uma resposta `Choice` permanece dentro das opções declaradas, e a estrutura segue o schema.

É uma propriedade importante. Um valor fora do enum ou um JSON quebrado pode derrubar uma integração, acionar um retry ou atravessar várias dependências antes de falhar.

Mas o schema só limita como o erro pode chegar.

O Jev ainda pode escolher `billing` quando o destino correto era `technical`. Pode atribuir baixa probabilidade a um caso urgente. Pode devolver uma resposta perfeitamente válida para uma pergunta mal escrita.

Por isso eu leria a frase "não alucina" de forma estreita. O modelo não inventa uma saída fora do espaço permitido. Isso não significa que a saída escolhida corresponde à realidade.

O problema não é o formato. É a decisão dentro dele.

## O melhor caso tem quatro propriedades

Eu usaria o Jev quando o problema reúne quatro condições.

Primeiro, a resposta cabe num conjunto conhecido. Filas de suporte, categorias de documento, níveis de risco e handlers de uma aplicação têm opções que o código consegue enumerar.

Segundo, existe julgamento semântico. Se uma expressão regular ou uma comparação resolve o caso de forma exata, o modelo não acrescenta nada. O ganho aparece quando duas mensagens com palavras diferentes significam a mesma intenção, ou quando uma regra escrita à mão cresce até virar uma coleção frágil de exceções.

Terceiro, a decisão acontece com frequência suficiente para custo e latência importarem. A TypeSafe publica preço de US$ 0,042 por milhão de tokens de entrada e não cobra pelos tokens de saída. Também reporta respostas entre 70 e 500 milissegundos em sua infraestrutura. São números da empresa, não uma medição independente, mas explicam a forma de uso pretendida: decisões dentro do fluxo da aplicação.

Quarto, existe uma rota segura para incerteza. O sistema pode pedir confirmação, chamar outro componente ou enviar o caso para uma pessoa.

Alguns encaixes concretos:

| Decisão | Tipo | O que o código faz depois |
| --- | --- | --- |
| Escolher a fila de atendimento | `Choice` | Encaminha ou pede triagem manual |
| Avaliar relevância de um trecho recuperado | `Score` | Mantém, descarta ou marca para review |
| Detectar se uma mensagem pede reembolso | `Noul` | Aplica um threshold definido pelo produto |
| Selecionar uma ferramenta de baixo risco | `Choice` | Executa apenas ferramentas permitidas |
| Avaliar uma saída de outro modelo | `Noul` ou `Score` | Libera, bloqueia ou escala |

O Jev decide entre opções. O código continua sendo dono do efeito.

## Confiança só ajuda quando muda o fluxo

Respostas `Choice` e `Score` incluem uma distribuição de probabilidades. O campo `confidence` resume quão concentrada está essa distribuição. `Noul` já devolve a própria probabilidade e não traz um campo separado de confiança.

Ler apenas a opção vencedora desperdiça metade do contrato.

Uma classificação pode produzir `billing: 0.42`, `technical: 0.39` e `sales: 0.19`. `billing` venceu, mas o resultado não sustenta a mesma automação de uma distribuição `0.96`, `0.03`, `0.01`.

Eu separaria pelo menos três comportamentos no código:

```python
if answer.confidence < review_floor:
    send_to_human(case)
elif answer.choice == "technical":
    route_to_technical(case)
else:
    route_to_selected_queue(case)
```

Os valores de `review_floor` não vêm da documentação do modelo. Eles precisam sair de exemplos rotulados do próprio fluxo e variar conforme o custo do erro. Mostrar uma tela errada é recuperável. Aprovar uma transferência não é.

Confiança declarada também não substitui calibragem medida. Antes de automatizar, eu compararia faixas de confiança com a taxa real de acerto em dados representativos. Depois acompanharia essa relação em produção para detectar mudança de distribuição.

## O que deve permanecer no código

A própria TypeSafe documenta uma lista extensa de limites do `jev-1.13`. Ela ajuda a separar julgamento de computação.

Contagem, aritmética e comparação de datas ficam no código. O Jev lê datas como texto, não como quantidades ordenadas. Se a regra diz "mais de 30 dias", a aplicação calcula a diferença.

Invariantes também ficam no código. Duas perguntas separadas não precisam obedecer a identidades como `P(A) + P(não A) = 1`. Se o sistema precisa dessa relação, deve fazer uma pergunta só ou impor a regra depois.

Estado grande precisa de filtro anterior. Detalhes irrelevantes reduzem a acurácia e dificultam descobrir por que uma decisão saiu errada. Recuperação, parsing e seleção de campos acontecem antes da chamada.

Política obrigatória não vira prompt. Limites de autorização, saldo disponível, allowlists e regras regulatórias continuam como condições determinísticas.

Essa divisão deixa o Jev com a parte que pede interpretação e deixa o software com aquilo que pode provar.

## Onde Jev não cabe

Jev não é um modelo para geração. Se a saída esperada é um email, código, resumo, plano ou explicação, a aplicação precisa de outra ferramenta.

Também não é indicado para raciocínio com várias etapas. A documentação reconhece perda de qualidade com indirection, negações complexas e perguntas sobre propriedades de propriedades. O caminho seguro é reduzir cada decisão a uma pergunta direta e combinar os resultados em código.

Eu não usaria o `jev-1.13` como única barreira contra conteúdo adversarial. A TypeSafe avisa que o estado não é tratado como hostil por padrão e que uma instrução injetada no conteúdo pode mover a resposta. O modelo pode ser um sinal de um sistema de guardrails, mas não substitui isolamento, validação e regras explícitas.

Também não entregaria ao modelo a decisão final em crédito, saúde, emprego, segurança ou qualquer operação irreversível. Uma probabilidade pode ordenar uma fila ou apontar casos para revisão. Ela não fornece evidência, explicação causal nem responsabilidade pelo resultado.

Por fim, Jev não corrige uma taxonomia ruim. Se as opções se sobrepõem, deixam lacunas ou mudam toda semana, a saída tipada apenas torna a ambiguidade mais organizada.

## A integração precisa ter uma saída de emergência

Antes de adotar o Jev, eu responderia cinco perguntas:

1. O conjunto de respostas é realmente fechado?
2. Qual parte exige julgamento, e qual parte pode ser calculada?
3. O que acontece quando a confiança é baixa?
4. Qual erro pode executar uma ação irreversível?
5. Existe um conjunto rotulado para ajustar os thresholds e detectar regressões?

Se a terceira pergunta não tem resposta, o sistema ainda não está pronto para automação. Se a quarta aponta para dinheiro, acesso ou segurança, confiança alta não basta. O fluxo precisa de confirmação ou review.

Jev oferece uma interface incomum para IA: estado entra, decisões tipadas saem. Isso reduz o espaço de falha e torna probabilidades parte explícita do código.

Não transforma julgamento em certeza.

> Se o modelo escolher uma opção válida e errada, qual parte do sistema impede que essa resposta vire uma ação?

## Fontes

- [Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [TypeSafe API reference](https://docs.typesafe.ai/api)
- [TypeSafe: Confidence](https://docs.typesafe.ai/confidence)
- [TypeSafe: State](https://docs.typesafe.ai/concepts/state)
- [Jev 1.13 jaggedness](https://docs.typesafe.ai/model-jaggedness/jev-1.13)
- [TypeSafe: Jev 1.13 na OpenRouter](https://openrouter.ai/typesafe/jev-1.13)
- [TypeSafe AI's Jev now available on AI Gateway](https://vercel.com/changelog/typesafe-ai-jev-now-available-on-ai-gateway)
