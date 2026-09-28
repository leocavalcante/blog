---
title: "CLM escolhe rápido quando as opções não mudam"
description: "O CLM lê a situação e cada opção em separado e escolhe a mais parecida. Fica rápido quando as opções se repetem, e fraco quando a frase pede nuance."
date: "2026-10-01T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - agent
    - evaluation
    - reliability
    - cost-management
url: /clm-escolhe-rapido-quando-as-opcoes-nao-mudam/
cover: cover.jpg
cover_alt: "Chaves penduradas em aros de arame, em duas fileiras, num expositor com etiquetas escritas à mão."
cover_credit_name: "YoNeKeN"
cover_credit_url: "https://unsplash.com/photos/a-bunch-of-keys-are-hanging-on-a-rack-EuMV9-MZAuQ"
---

Mandei este chamado, com duas opções. "My invoice was charged twice and nobody answers the phone!" O CLM devolveu billing a 0,989 e technical a 0,011. Ele não escreveu um texto. Leu o chamado, leu cada opção, e ficou com a mais parecida.

O README abre com outro teste, o dinossauro do Chrome. CLM e Jev passaram por cinco tentativas de 60 segundos sem morrer. O CLM respondeu em 16,5 ms de mediana. O Jev, em 149,8 ms.

O arquivo de resultados do mesmo teste mostra o resto. O CLM escolheu a mesma jogada que o planner de física em 65,8% das decisões. O Jev, em 98,7%. Nas cinco tentativas do CLM, o escudo do teste interveio 4.883 vezes. Nas do Jev, 28. Esse escudo troca uma resposta que o planner marcou como insegura pela opção segura mais provável.

Os dois números medem coisas diferentes. A sobrevivência inclui o escudo. A concordância com o planner é o modelo sozinho.

**O CLM lê a situação e cada opção em separado, guarda o que já leu, e escolhe a opção mais parecida. Fica rápido quando as mesmas opções voltam. Quando a frase pede nuance, os números publicados e o único teste independente que encontrei deixam o CLM atrás do Jev.**

## O CLM escolhe a opção mais parecida com a situação

Pesquisadores de Stanford e da Nvidia, segundo a VentureBeat, publicaram o CLM em 23 de setembro de 2026, com código e pesos sob Apache 2.0. O nome é Contrastive Language Models. O primeiro modelo é o CLM-8B.

A entrada é a situação, o campo `state`, e uma lista fechada de opções. Cada opção tem um nome e uma descrição. No chamado acima, a situação é a frase do cliente. As opções são billing e technical.

Um Qwen3-8B congelado lê cada texto e devolve uma lista de números, o embedding do último token. Congelado quer dizer que esses 8 bilhões de parâmetros não entram no treino. O README chama o resto de dois encoders, um da situação e um da opção. Na hora de servir, os dois usam esse mesmo Qwen. O que muda é um módulo de projeção pequeno para cada lado. Cada módulo comprime a lista para 512 números.

A nota de uma opção é o cosseno entre as duas listas, o quanto elas apontam para o mesmo lado, multiplicado por uma escala que o treino aprende. Um softmax converte essas notas em probabilidades que somam 1. Por isso 0,989 e 0,011 somam 1. A maior ganha.

O arquivo publicado com os dois módulos tem 75 MB. O Qwen fica de fora e roda à parte, num vLLM que devolve um vetor por texto em vez de gerar a próxima palavra.

"Resetar senha" produz a mesma lista em qualquer chamado. Se o agente escolhe sempre entre as mesmas 50 ações, o Qwen lê cada uma uma vez e o servidor guarda o resultado. Na decisão seguinte, só a situação nova passa pelo modelo grande.

O treino usa InfoNCE nos dois sentidos. Num lote de pares, a situação tem que ficar mais perto da própria ação do que das ações dos outros pares. A ação também tem que ficar mais perto da própria situação do que das outras situações.

O README descreve três etapas.

- Pré-treino em cerca de 60 milhões de pares de pergunta e resposta do Nemotron.
- Mid-training com cerca de 30 milhões de hard negatives, respostas parecidas com a certa e mesmo assim erradas, geradas pelo Gemini 2.5 Flash-Lite.
- Pós-treino em cerca de 1 milhão de trajetórias de agentes. Cada passo vira um par entre o contexto e a ação tomada.

A ordem aparece nos números do próprio time. Em cerca de 100 mil perguntas, com uma resposta certa e dez parecidas e erradas, o pré-treino sozinho acerta 52,1% no top-1. Um mid-training curto leva a 69,2%. Treinar com essas respostas parecidas desde o começo chega a 62,4% e depois cai. O README chama essa queda de overfitting.

A API segue o formato da TypeSafe. Um request escrito para o Jev, com `state` e perguntas `choice`, `score` ou `noul`, roda no `clm-serve` se você troca a URL e a chave. `choice` escolhe uma opção. `score` devolve uma nota. `noul` devolve uma probabilidade de sim ou não. Por baixo, cada pergunta vira a situação mais uma lista de textos. O endpoint `rank` faz o mesmo com candidatos livres, como N soluções propostas por um agente.

## A diferença para Jev e Laya é o que dá para guardar

Jev, Laya e CLM respondem essas três perguntas. O caminho até a nota muda.

O Laya põe situação, pergunta e opções no mesmo texto de entrada, com um marcador `[MASK]` por opção, [como descrevi no post sobre ele](/laya-decisoes-tipadas-com-pesos-abertos/). Cada opção é lida junto com a situação. A TypeSafe não publicou a arquitetura do [Jev](/jev-garante-o-formato-nao-a-decisao/).

No CLM, situação e opção só se encontram na hora do cosseno. Jacky Kwok, primeiro autor do paper, disse à VentureBeat que Jev e Laya guardam principalmente a representação da situação, enquanto o CLM calcula e guarda situação e opção em separado. A leitura sobre o Jev é dele. O lado do CLM está no código.

O README mede o cache numa RTX 4090, com um conjunto fixo de ações. Com situação nova a cada chamada, a mediana no servidor foi de 28,6 ms sem o cache de vetores e 28,0 ms com ele. Com situações já vistas, caiu de 1,7 ms para 0,6 ms. O cache ajuda quando o agente volta a uma situação que já passou pelo Qwen. Uma situação nova ainda espera o encoder inteiro.

| | Jev (TypeSafe) | Laya (ConvAI) | CLM-8B |
| --- | --- | --- | --- |
| Pesos | Fechados, API hospedada | Apache 2.0 | Apache 2.0 |
| Modelo | Arquitetura não publicada | ModernBERT-large, 421M | Qwen3-8B congelado + dois módulos de projeção |
| Situação e opções | Não publicado | No mesmo texto de entrada | Lidos em separado |
| O que você baixa | Nada | Cerca de 800 MB (checkpoint inglês) | 75 MB dos módulos + 15,26 GiB do Qwen3-8B |
| Custo marginal | US$ 0,042 por milhão de tokens de entrada | Compute próprio | Compute próprio, com GPU para um modelo de 8B |
| Fine-tuning pelo cliente | Sem oferta pública | Notebook oficial | Treina apenas os módulos de projeção, com o Qwen congelado |

## Os benchmarks do README comparam CLM e Jev

Não encontrei número publicado de CLM contra Laya. O README compara com o Jev em dois blocos.

O primeiro não teve treino extra na tarefa. Usa os módulos de projeção publicados.

| Tarefa | Latência CLM | Latência Jev | Sucesso CLM | Sucesso Jev |
| --- | ---: | ---: | ---: | ---: |
| T-Rex | 16,5 ms | 149,8 ms | 5/5 | 5/5 |
| Tool calling (BFCL v4) | 76,8 ms | 125,5 ms | 95,2% | 99,2% |
| WikiRacing | 79,8 ms | 225 ms | 26/30 | 30/30 |
| Super Mario | 33,5 ms | 132,6 ms | 5/5 | 5/5 |

O "até 9x mais rápido" é o T-Rex. 149,8 dividido por 16,5. Nas outras três tarefas, a razão fica entre 1,6x e 4x. Em tool calling e WikiRacing, o Jev acertou mais.

A latência mistura duas medições. O CLM rodou numa RTX 4090 local. O Jev respondeu pela API da TypeSafe. As duas latências foram medidas no cliente, e o próprio exemplo do T-Rex registra isso. Uma inclui a rede. A outra quase não tem rede.

T-Rex e Super Mario são cinco tentativas cada. WikiRacing marca 26 de 30 para o CLM e 30 de 30 para o Jev. No T-Rex, o planner já escreve "Safe" ou "Unsafe" no texto de cada opção. O modelo escolhe entre rótulos que o teste calculou, e o escudo ainda pode trocar a resposta.

O segundo bloco usa o CLM como verificador. Um modelo maior gera várias soluções por tarefa, Opus 5 no DeepSWE e Fable 5 no Terminal-Bench 2.1. O verificador escolhe qual submeter. A linha "escolher ao acaso" é o pass@1, a taxa de acertar se a escolha entre os candidatos fosse aleatória.

| | DeepSWE | Terminal-Bench 2.1 |
| --- | ---: | ---: |
| Tarefas fora do treino | 38 | 30 |
| Candidatos por tarefa | 4 | 5 |
| Escolher ao acaso | 73,7% | 84,0% |
| CLM com módulos ajustados | 81,6% | 87,6% |
| Jev | 71,1% | 83,1% |
| Latência CLM / Jev, numa H100 | 79 / 449 ms | 32 / 131 ms |

No DeepSWE, a diferença para o acaso são três tarefas. 31 de 38 contra 28 de 38. O card do checkpoint publica o teto. Um verificador perfeito acertaria 34 de 38. O Jev ficou em 27 de 38, uma tarefa abaixo do acaso.

No Terminal-Bench, o CLM marca 87,6% e o Jev 83,1%, contra 84,0% de escolher ao acaso. 87,6% de 30 tarefas não fecha uma contagem inteira. O README não diz sobre quantas rodadas a média foi calculada.

O recorte que eu mais pesaria é o treino. O CLM dessas linhas teve os módulos ajustados em 59 tarefas do próprio DeepSWE, separadas das 38 de teste. O Jev entrou sem esse ajuste, porque não tem fine-tuning público. É o mesmo recorte que [já apareceu com o Laya](/jev-laya-ou-classificador-proprio/). Um especialista treinado no benchmark contra um generalista que nunca o viu. O resultado mostra que ajustar os módulos funciona. Não mostra que o CLM julga melhor que o Jev.

## O teste independente que encontrei pesa contra a nuance

Um autor no Zenn comparou CLM-8B, Jev, Kev-4B e Qwen3.5-4B numa RTX 3090. Montou 13 casos em que a frase parece uma coisa e a resposta é outra. O menino que grita "lobo!" está mentindo, e não está disfarçado. Alguém de máscara por causa de rinite alérgica não está escondendo a identidade. O CLM acertou 4 de 13 num prompt e 5 de 13 no outro. O Jev acertou 12 e 11. O autor atribui os erros do CLM a palavras como "segredo", "mentira" e "máscara". Elas puxam a lista de números para a opção errada mesmo quando a frase diz o contrário.

Outro teste tinha três opções, quase certo, incerto e impossível. Eram dois cenários com evidência ambígua, uma investigação interna e uma previsão de cancelamento. A opção do meio recebeu 1,7% e 1,1% no CLM. O Jev deu 75% e 67% a ela. Se o fluxo manda o caso incerto para uma pessoa, nesses dois cenários o CLM quase não manda.

O CLM foi bem ao rejeitar entidades e resultados científicos inventados, com 94,8% a 96,0% de probabilidade no "não".

São 13 casos e dois cenários, escritos por um autor só. Não sustentam um ranking. A nota é semelhança entre duas listas, e frases com as mesmas palavras tendem a ficar perto.

## Rodar no Modal pede uma GPU de 24 GB

Não existe API hospedada do CLM. O `clm-serve` é a API, e roda onde você colocar. O Hugging Face hospeda os pesos e não oferece inferência para esse checkpoint. O caminho mais curto que encontrei foi o Modal. Ele cobra a GPU por segundo e desliga o container quando os requests param.

O Qwen3-8B em bf16 ocupou 14,11 GiB na L4 do Modal, segundo o log do vLLM. Sobraram 5,47 GiB para o contexto, com limite de 2.048 tokens. Uma L4 de 24 GB basta. Os módulos de projeção rodam em CPU.

O arquivo sobe dois processos no mesmo container. O vLLM serve o Qwen na GPU e responde embeddings em localhost. O `clm-serve` calcula as notas na CPU e é a única porta exposta. Cortei da versão abaixo o código que desliga os processos e parte da configuração de cache.

```python
import subprocess
import time
import urllib.request

import modal

app = modal.App("clm")

image = (
    modal.Image.debian_slim(python_version="3.12")
    .uv_pip_install("vllm==0.21.0", "contrastive-lm==0.1.0")
    .env({
        "HF_HOME": "/cache/huggingface",
        "VLLM_CACHE_ROOT": "/cache/vllm",
        "CLM_CKPT_DIR": "/cache/clm",
    })
)
cache = modal.Volume.from_name("clm-cache", create_if_missing=True)


def wait_for(url: str, timeout_s: int) -> None:
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(url, timeout=5) as r:
                if r.status == 200:
                    return
        except OSError:
            pass
        time.sleep(5)
    raise TimeoutError(url)


@app.server(
    image=image,
    gpu="L4",
    cpu=4,
    memory=32768,
    volumes={"/cache": cache},
    port=8700,
    startup_timeout=20 * 60,
    scaledown_window=5 * 60,
    max_containers=1,
)
class Server:
    @modal.enter()
    def start(self):
        self.vllm = subprocess.Popen([
            "vllm", "serve", "Qwen/Qwen3-8B",
            "--served-model-name", "qwen3-8b",
            "--runner", "pooling",
            "--pooler-config", '{"task":"embed","pooling_type":"LAST"}',
            "--dtype", "bfloat16",
            "--max-model-len", "2048",
            "--gpu-memory-utilization", "0.90",
            "--enforce-eager",
            "--enable-prefix-caching",
            "--host", "127.0.0.1", "--port", "8090",
        ])
        wait_for("http://127.0.0.1:8090/health", 18 * 60)
        self.clm = subprocess.Popen([
            "clm-serve", "--port", "8700",
            "--emb-url", "http://127.0.0.1:8090/v1/embeddings",
            "--device", "cpu",
            "--action-cache", "0",
            "--no-ui",
        ])
        wait_for("http://127.0.0.1:8700/health", 3 * 60)
        cache.commit()
```

Três escolhas desse arquivo mudam custo e latência. `--enforce-eager` desliga CUDA graphs e `torch.compile`. O container sobe mais rápido, e cada passagem pelo modelo fica mais lenta. `--device cpu` e `--action-cache 0` deixam a GPU inteira para o vLLM, então o cache de vetores do CLM fica desligado. O `clm-serve` ainda guarda na memória os embeddings que já viu, e esquece os mais antigos quando essa memória enche. `max_containers=1` limita a conta a uma GPU.

Para publicar e criar a credencial de acesso:

```bash
modal token new
modal deploy app.py
modal workspace proxy-tokens create
```

O endpoint fica atrás da autenticação de proxy do Modal. A chamada leva os headers `Modal-Key` e `Modal-Secret` com o token criado no último comando:

```bash
curl -s "https://<workspace>--clm-server.us-east.modal.direct/v1/systemone" \
  -H "Modal-Key: $MODAL_KEY" \
  -H "Modal-Secret: $MODAL_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "Customer: my invoice was charged twice and nobody answers the phone!",
    "questions": {
      "department": {
        "type": "choice",
        "instructions": "Which team should handle this?",
        "criteria": {
          "billing": "Charges, invoices, refunds",
          "technical": "Bugs and outages"
        }
      }
    }
  }'
```

Nesse exemplo, com as duas opções do começo, a resposta veio com billing a 0,989 e technical a 0,011.

## Do Brasil, a rede pesa mais que o modelo

Os números abaixo são de requests enviados do Brasil para uma L4 do Modal em us-east, com esse arquivo.

A primeira subida levou cerca de 4 minutos e meio até a primeira resposta. 150 segundos foram o download dos pesos do Qwen3-8B. Com os pesos já no volume, a segunda subida levou cerca de 76 segundos entre o primeiro request, que voltou 503, e o servidor pronto. O vLLM carregou os pesos em 12,7 segundos.

Com o container quente, mandei duas perguntas por request, uma `choice` de três opções e uma `noul`.

| Caso | Requests | p50 no servidor | p50 no cliente | p95 no cliente |
| --- | ---: | ---: | ---: | ---: |
| Situação e opções já vistas | 50 | 7,3 ms | 518,5 ms | 676,9 ms |
| Situação nunca vista | 30 | 146,4 ms | 674,8 ms | 922,4 ms |

Quando o texto já passou pelo Qwen, o servidor responde em milissegundos. A rede e o proxy do Modal somam cerca de meio segundo em cima disso, e esses dados não separam um do outro. No [post da comparação](/jev-laya-ou-classificador-proprio/), o Jev hospedado teve p50 de 0,37 s, com requests também saindo do Brasil. Os dias, as cargas e os requests são diferentes. Nessa distância, o CLM no Modal ficou mais lento de ponta a ponta que o Jev.

Com situação nova, o servidor levou 146 ms, bem acima dos 28 ms que o README mede numa RTX 4090. A L4 é uma GPU menor, e `--enforce-eager` custa latência. Não medi quanto vem de cada um.

Também escrevi dez chamados curtos com resposta óbvia. Quatro de billing, três de technical e três de sales. O CLM acertou 8 de 10. Os dois erros foram chamados técnicos mandados para sales. Um sobre erro 500 no dashboard, outro sobre a API rejeitando um token. A pergunta `noul` "Is this urgent?" ficou entre 0,60 e 0,86 nos dez, incluindo 0,70 para quem pergunta se há desconto para ONGs. Nesses dez, ela não separou urgente de rotina. Dez frases que eu escrevi são uma checagem de sanidade, não um benchmark.

O chamado de cobrança duplicada teve `confidence` de 0,979 com duas opções. Coloquei `sales` como terceira, e o número caiu para 0,326. Billing continuou vencendo. As probabilidades são relativas às opções que você mandou, como o card do modelo avisa. Um corte ajustado com duas opções não vale para três.

A L4 custa US$ 0,000222 por segundo no Modal, cerca de US$ 0,80 por hora. CPU e memória são cobrados à parte. Com 4 núcleos e 32 GiB, isso soma cerca de US$ 0,45 por hora. O container desliga depois de 5 minutos sem request, e cada subida espera o boot de novo.

## Onde eu colocaria o CLM

Eu usaria o CLM quando um agente escolhe muitas vezes entre ações que não mudam, a situação se repete ou chega em lote, e a GPU fica perto de quem chama. Roteamento de ferramentas num catálogo fixo e ranking de N soluções candidatas são os casos que o próprio time mostra.

O ajuste dos módulos vale quando existe um conjunto de trajetórias com resultado conhecido. O Qwen continua congelado. Os resultados de verificador do README vêm desse ajuste.

Sozinho, eu não deixaria o CLM numa pergunta com opção "incerto" que manda o caso para uma pessoa, num julgamento que depende de negação ou de quem revelou o quê, nem num `noul` que ainda não mostrou que separa os casos do fluxo. Nesses pontos, o Jev acertou mais nos números que encontrei.

Como no Jev e no Laya, a resposta ainda é uma das opções que você mandou. Se todas estiverem erradas, ele escolhe uma errada.

> As ações que o seu agente escolhe são as mesmas a cada chamada, ou mudam junto com a situação?

## Fontes

- [Contrastive-LM/CLM no GitHub](https://github.com/Contrastive-LM/CLM)
- [T-Rex runner: CLM vs Jev](https://github.com/Contrastive-LM/CLM/blob/main/examples/t_rex/README.md)
- [Resultados do T-Rex para o CLM](https://github.com/Contrastive-LM/CLM/blob/main/examples/t_rex/results/clm_realtime.json)
- [Resultados do T-Rex para o Jev](https://github.com/Contrastive-LM/CLM/blob/main/examples/t_rex/results/jev_realtime.json)
- [CLM-v0.1-8B no Hugging Face](https://huggingface.co/Contrastive-LM/CLM-v0.1-8B)
- [DeepSWE CLM heads no Hugging Face](https://huggingface.co/Contrastive-LM/deepswe-clm-heads-8k)
- [Stanford and Nvidia's open CLM-8B caches reusable agent actions, VentureBeat](https://venturebeat.com/technology/stanford-and-nvidias-open-clm-8b-caches-reusable-agent-actions-and-runs-up-to-9x-faster-than-jev-in-tests)
- [Evaluating CLM-8B as a System 1 Decision Engine vs Jev and Kev, Zenn](https://zenn.dev/null_teck/articles/clm-vs-decision-models)
- [Modal: preços](https://modal.com/pricing)
- [Modal: vLLM inference](https://modal.com/docs/examples/vllm_inference)
- [Jev garante o formato. Não garante a decisão](/jev-garante-o-formato-nao-a-decisao/)
- [Laya tem pesos abertos. A operação fica com você](/laya-decisoes-tipadas-com-pesos-abertos/)
- [Dissecando o hype das decisões tipadas: Jev, Laya ou classificador próprio](/jev-laya-ou-classificador-proprio/)
