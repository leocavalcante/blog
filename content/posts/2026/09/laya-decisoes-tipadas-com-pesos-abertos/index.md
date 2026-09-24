---
title: "Laya tem pesos abertos. A operação fica com você"
description: "Laya é um modelo de decisão não autorregressivo com pesos Apache 2.0. Ele troca a conveniência de uma API hospedada pelo controle de rodar, avaliar e especializar o modelo."
date: "2026-09-24T15:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - reliability
    - developer-experience
    - cost-management
url: /laya-decisoes-tipadas-com-pesos-abertos/
cover: cover.jpg
cover_alt: "Cabos de rede organizados em um rack de datacenter."
cover_credit_name: "Taylor Vick"
cover_credit_url: "https://unsplash.com/photos/cable-network-M5tzZtFCOfs"
---

Em setembro de 2026, poucos dias depois do lançamento do Jev, a ConvAI Innovations publicou o Laya. Os dois recebem um estado, respondem perguntas tipadas e não geram texto. Só o Laya distribui pesos e código sob licença Apache 2.0.

**A diferença mais clara entre Laya e Jev está na entrega. Laya é aberto e self-hosted. Jev é acessado por uma API hospedada.**

Se você já leu [o post sobre Jev](/jev-garante-o-formato-nao-a-decisao/), o contrato é familiar: `state` entra, `choice`, `score` ou `noul` saem com probabilidades. O que muda é quem opera o modelo e quanto trabalho fica com o time que o adota.

## Laya é uma família de checkpoints

A ConvAI descreve o Laya como um modelo System 1. A TypeSafe usa System One para a própria classe de modelos e apresenta Jev como o primeiro deles. Os nomes não provam uma arquitetura comum, mas as duas interfaces cobrem os mesmos três tipos de pergunta.

A ConvAI publica três checkpoints no hub `convaiinnovations/laya`:

| Checkpoint | Encoder | Parâmetros | Contexto | Uso principal |
| --- | --- | --- | --- | --- |
| raiz (inglês) | ModernBERT-large | 421M | 512 | Inglês, triagem, guardrails |
| `multilingual` | mmBERT-base | 322M | 1024 (encoder até 8192) | 100+ idiomas declarados no card |
| `typed-decisions` | ModernBERT-large | 421M | 1024 | Workflows de decisão tipada |

Os três ficam no mesmo repositório. O SDK baixa a raiz ou apenas o subdiretório solicitado. O pacote Python (`pip install laya`) carrega um checkpoint, monta o estado e as perguntas e devolve respostas tipadas em um forward pass. Não há endpoint de chat. Não há texto livre na saída.

Isso permite rodar offline, em uma VPC ou em hardware próprio. Também permite ler a implementação, baixar os pesos e ajustar o modelo. Jev publica API, preço, documentação de limites e evals. A arquitetura e os pesos do Jev não são públicos.

## O modelo pontua opções em vez de gerar JSON

No checkpoint inglês, a ConvAI usa um encoder bidirecional (ModernBERT-large, 395M parâmetros no backbone) e um head de decisão treinado do zero. Cada opção de uma pergunta `choice` recebe um marcador `[MASK]`. Depois das camadas do encoder, o head transforma o vetor daquele marcador em um logit. Um softmax por pergunta produz a distribuição entre as opções que você definiu na chamada.

Perguntas `score` usam a mesma mecânica sobre níveis ordinais de uma régua. `noul` devolve a probabilidade de uma afirmação binária.

Todas as perguntas de uma chamada rodam no mesmo forward pass. A latência total cresce com o número de perguntas, mas o custo por pergunta cai quando elas são agrupadas. No benchmark publicado pela ConvAI, o checkpoint multilíngue passou de 32,8 ms com uma pergunta para 72,3 ms com dez em uma T4.

O treinamento do Laya usa recompensas baseadas em strictly proper scoring rules para aproximar a confiança reportada da frequência de acerto observada. A ConvAI chama a receita de RLCD (Reinforcement Learning for Calibrated Decisions), o mesmo nome usado pela TypeSafe. Isso não prova que os dois modelos foram treinados da mesma forma: a TypeSafe não publicou a receita completa do Jev.

### O checkpoint inglês confia em scripts que não lê

No benchmark MASSIVE, Khmer chegou a 0,000 de acurácia com confiança média de 0,952 no checkpoint inglês, segundo números publicados pela ConvAI. Se você usa confiança para automatizar, precisa rotear antes da inferência.

O `Router` inspeciona o texto, detecta script e indícios do idioma sem carregar outro modelo, e escolhe entre inglês, multilíngue ou um override explícito. Com `preload=True`, os checkpoints ficam residentes e a troca de idioma não paga reload a cada request. O custo é manter mais de um modelo na memória.

## Exemplo mínimo

```python
import laya

agent = laya.load("convaiinnovations/laya")

state = {
    "subject": "Duplicate charge on invoice #4411",
    "body": "We were billed twice for March. Refund the duplicate or we cancel.",
}

questions = {
    "department": {
        "type": "choice",
        "instructions": "Which department should handle this request?",
        "criteria": {
            "billing": "invoices, payments, refunds",
            "technical": "bugs, outages",
            "sales": "pricing, contracts",
        },
    },
    "churn_risk": {
        "type": "noul",
        "instructions": "Does the sender threaten to cancel?",
    },
}

result = agent.predict(state, questions)
print(result["answers"]["department"]["choice"])
print(result["answers"]["churn_risk"]["noul"])
```

O schema se parece com o de uma integração Jev. A diferença está no runtime: aqui você baixa cerca de 800 MB para o checkpoint inglês, provisiona CPU ou GPU e mantém o processo.

## Controle de deploy justifica o trabalho extra

Eu consideraria Laya quando o controle de deploy e de treino pesa tanto quanto a conveniência da integração.

Hospedagem própria ou air-gap é o caso mais direto. Os pesos têm licença Apache 2.0 e a inferência não depende de uma API externa. Para triagem interna ou roteamento de dados sensíveis, isso pode ser requisito.

Fluxos multilíngues pedem roteamento explícito. A ConvAI publica resultados para 51 idiomas e oferece um checkpoint dedicado. Nesse sweep, 45 dos 51 ficaram acima do critério de três vezes o acaso usado no card. Não encontrei um benchmark multilíngue equivalente para Jev.

Fine-tuning no próprio domínio é o caso em que os pesos abertos mais mudam o trabalho. No benchmark typed-decisions (2.000 decisões em quatro workflows), o checkpoint especializado `typed-decisions` reporta 0,766 de acurácia. O checkpoint inglês base fica em 0,362, abaixo do baseline de 0,461 obtido ao escolher sempre a classe mais comum. O multilíngue também fica abaixo desse baseline, embora duas seções do model card publiquem valores diferentes para ele. A ConvAI publica um notebook de fine-tuning para 2×T4 no Kaggle. A diferença entre esses números é um aviso para treinar e medir no fluxo real.

Em volume alto, o modelo de custo também muda. Jev cobra US$ 0,042 por milhão de tokens de entrada, segundo a TypeSafe. Laya troca a cobrança por request por hardware, energia e operação. Qual opção custa menos depende da utilização e da infraestrutura disponível.

Pesos e código abertos deixam o time inspecionar a arquitetura, reproduzir avaliações e manter checkpoints próprios.

Os mesmos fluxos do Jev continuam valendo: fila de suporte, relevância de trecho RAG e scoring de risco com opções fechadas. A diferença é o caminho até produção: você provavelmente vai treinar, calibrar temperatura no seu hold-out e medir de novo.

## O model card mostra onde Laya perde

Laya não escreve email, código ou plano. Contagem, cálculo de datas e regras exatas continuam melhores em código.

Também não trataria o modelo como única barreira contra conteúdo adversarial. A ConvAI publica resultados de detecção de jailbreak no ToxicChat. Isso mede Laya como detector, não sua resistência a instruções injetadas no próprio `state`, que o benchmark não avalia. Guardrails, permissões e validação continuam no software.

O resultado de 0,766 pertence ao especialista treinado no split de treino do benchmark. Os checkpoints base não chegam ao baseline majoritário nessa avaliação.

Em Banking77, com 77 rótulos, Laya reporta 0,425 no card. A comparação publicada para Jev 1.13.0 usa 72 rótulos e reporta 0,870. Não é um confronto controlado, mas expõe o limite do budget `head_max_len` do Laya. Para catálogos grandes, a própria ConvAI recomenda shortlist com embeddings, aumento de budget ou hierarquia coarse-to-fine. Jev aceita até 255 opções, embora a TypeSafe também descreva um processo em duas etapas para conjuntos maiores.

Calibração também exige trabalho local. No typed-decisions, o especialista reporta ECE bruto de 0,213. A ConvAI recomenda ajustar temperatura por tipo de pergunta em dados separados. Uma distribuição só deve orientar automação depois que o time comparar confiança e acerto no próprio domínio.

A latência depende do hardware. Os 32,8 a 39,5 ms destacados no card foram medidos em uma Tesla T4. O mesmo card reporta 193 a 464 ms em CPU com preload, sem identificar um único processador de referência para toda a faixa. O número útil é o medido no hardware e no tamanho de batch da aplicação.

Hospedar o modelo também exige baixar pesos, reservar memória, manter versões de PyTorch e operar uma fila de inferência. Jev entrega essa parte como serviço.

## A comparação não é um head-to-head controlado

Os dois modelos respondem perguntas tipadas sobre o mesmo `state`. A comparação útil separa produto, capacidade out-of-the-box e custo de operação.

| Dimensão | Jev (TypeSafe) | Laya (ConvAI) |
| --- | --- | --- |
| Acesso | API hospedada, pesos fechados | Pesos Apache 2.0 + SDK Python |
| Fine-tuning pelo cliente | Sem fine-tuning público | Notebook e checkpoints ajustáveis |
| Typed-decisions | 0,727 de terceiro, citado pela ConvAI | 0,766 no especialista; 0,362 no checkpoint inglês base |
| Opções por `choice` | Até 255 documentadas | O card alerta para degradação acima de 20 no default |
| Soft accuracy (typed-decisions) | 0,580 de terceiro, citado pela ConvAI | 0,471 no card do especialista |
| Banking77 | 0,870 de terceiro, citado pela ConvAI (72 rótulos) | 0,425 no card (77 rótulos, default) |
| Latência reportada (medidas diferentes) | 70 a 500 ms, serviço hospedado | 32,8 a 39,5 ms em T4; 193 a 464 ms em CPU com preload |
| Multilíngue | Sem benchmark público equivalente | Router + checkpoint dedicado |
| Custo marginal | US$ 0,042 / MTok entrada | Compute self-hosted |
| Integrações | SDK da TypeSafe, Vercel AI Gateway | Hugging Face, pacote Python, notebook de fine-tuning |

A tabela tem duas limitações.

Primeiro, a ConvAI declara que os números de Jev vêm de publicações de terceiros e não foram medidos no mesmo harness. Quantidade de exemplos, prompts e, em Banking77, número de rótulos diferem. A latência também mistura medidas: a faixa do Jev é tempo fim a fim de um serviço hospedado, reportado pela TypeSafe; a do Laya é inferência local. O model card do Laya ainda cita medições de terceiros de 236 a 276 ms de p50 para Jev. A tabela descreve resultados publicados, não um ranking controlado.

Segundo, argmax e distribuição medem coisas diferentes. O especialista do Laya reporta 0,766 de acurácia dura no typed-decisions, contra 0,727 no número de terceiro citado para Jev. Na soft accuracy, os valores são 0,471 para Laya e 0,580 no número citado para Jev. A primeira mede a opção vencedora. A segunda mede proximidade com a distribuição do modelo usado como referência.

## O código continua dono da ação

O modelo interpreta texto dentro de opções fechadas. O código filtra estado, calcula datas, impõe allowlists, define thresholds de confiança e executa efeitos colaterais.

Antes de automatizar, eu mediria acurácia por faixa de confiança e separaria falsos positivos de falsos negativos no hold-out do fluxo real. Depois ajustaria temperatura por tipo de pergunta, como o card recomenda.

Se o catálogo passar de vinte opções, eu não forçaria uma única `choice`. Shortlist com embedding, pergunta coarse-to-fine ou split de domínio costuma sair mais barato do que empurrar 77 rótulos num budget de head apertado.

## A escolha é operacional

Pesos abertos dão controle. Também transferem para o time hospedagem, calibração, eval contínuo e ajuste por domínio. Jev concentra essa operação num serviço, mas não permite inspecionar ou hospedar o modelo.

Os dois reduzem erros de formato porque só respondem dentro das opções declaradas. Nenhum garante que a opção escolhida está correta. Essa distinção já valia para o [Jev](/jev-garante-o-formato-nao-a-decisao/) e não muda com pesos abertos.

Eu escolheria Laya quando hospedar e especializar o modelo faz parte do requisito. Escolheria Jev quando uma API hospedada e suporte a catálogos grandes importam mais que acesso aos pesos.

> Quanto controle sobre o modelo este fluxo precisa, e quem vai operar o que vier junto com esse controle?

## Fontes

- [convaiinnovations/laya no Hugging Face](https://huggingface.co/convaiinnovations/laya)
- [Laya no PyPI](https://pypi.org/project/laya/)
- [Laya: site da ConvAI](https://laya.convaiinnovations.com/)
- [Decoding Jev (Navin Pai)](https://navinpai.github.io/decoding-jev/)
- [Introducing System One Models and Jev (TypeSafe)](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [TypeSafe: Choice](https://docs.typesafe.ai/primitives/choice)
- [Jev no Vercel AI Gateway](https://vercel.com/ai-gateway/models/jev)
- [Jev guarantees the shape, not the decision (este blog)](/jev-garante-o-formato-nao-a-decisao/)
