---
title: 'Avaliando Agentes de IA Além do "Vibes Check": Como Medir o que Realmente Importa'
description: "Seu agente mandou bem na demo e todo mundo achou incrível. Mas como você sabe que ele realmente funciona? Se a resposta for 'a gente testou e pareceu bom', você está operando no modo vibes. E vibes não escalam."
date: "2026-06-29T10:00:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - evaluation
    - best-practices
url: /avaliando-agentes-de-ia-alem-do-vibes-check/
cover: cover.jpg
cover_alt: "Telescópio preto apontado para o horizonte durante o dia."
cover_credit_name: "Matthew Ansley"
cover_credit_url: "https://unsplash.com/@ansleycreative"
---

Seu agente mandou bem na demo e todo mundo achou incrível. O gerente de produto sorriu, o time de engenharia aplaudiu, e alguém já mandou no Slack: "isso vai mudar tudo". Mas como você _sabe_ que ele realmente funciona? Se a resposta for "a gente testou e pareceu bom", você está operando no modo _vibes_. E vibes não escalam.

Se você acompanha meus posts sobre [Agent Harness](/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/), [Tokenomics](/tokenomics-agentic-por-que-agentes-de-ia-estouram-sua-fatura-de-api/) e [Multi-Agentes](/sistemas-multi-agentes-de-ia-quando-usar-como-construir-e-porque-tantos-falham/), sabe que construir agentes de IA em produção é uma disciplina de engenharia, não de vibes. Hoje, vamos atacar o que considero a maior lacuna nesse ecossistema: **como avaliar se o seu agente de IA é confiável de verdade**.

## O problema do "Vibes-Driven Development"

Hamel Husain, uma das vozes mais respeitadas em AI Engineering, colocou de forma direta:

> "Produtos de IA que fracassam quase sempre compartilham uma causa raiz: a falha em criar sistemas de avaliação robustos."

Ele não está falando de startups amadoras. Está falando de times sofisticados que investem semanas refinando prompts e orquestrações, mas dedicam zero tempo à pergunta mais importante: _como eu sei que isso funciona?_

É um padrão que vejo se repetir com frequência preocupante. O time faz uma demo com 5 cenários pré-selecionados, todos passam, e o agente vai para produção. Duas semanas depois, os tickets de bug explodem. O agente alucinou uma resposta para um cliente, chamou a ferramenta errada, ou entrou em loop queimando tokens sem produzir resultado. Ninguém tem dados para entender _por que_ falhou, porque ninguém instrumentou a avaliação.

Isso é o "Vibes-Driven Development": tomar decisões com base em impressões subjetivas ao invés de métricas sistemáticas. É o equivalente a fazer deploy sem testes.

## Evals são os novos testes

Se você é Engenheiro de Software, já passou por essa evolução: houve um tempo em que testes unitários eram "coisa de quem tem tempo sobrando". Depois veio o TDD, o CI/CD, e hoje ninguém cogita fazer merge sem uma suíte verde. Evals para agentes de IA estão exatamente nesse ponto de inflexão.

A analogia é direta:

| Engenharia de Software | AI Engineering |
| --- | --- |
| Testes unitários | Evals de resultado |
| Testes de integração | Evals de trajetória |
| Testes de carga | Métricas de sistema (custo, latência) |
| Testes de segurança | Evals de compliance e segurança |
| CI/CD gates | Eval gates no pipeline |

A diferença crucial é que, diferente de software determinístico, agentes são _estocásticos_. Duas execuções da mesma tarefa podem produzir resultados diferentes. Isso significa que **a taxa de aprovação não precisa ser 100%, ela é uma decisão de produto**. Mas a decisão precisa ser informada por dados, não por vibes.

## As 4 camadas de avaliação de agentes

Quando falei sobre o [Agent Harness](/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/), expliquei que o desempenho de um agente depende de 6 camadas de engenharia. Agora, para _medir_ esse desempenho, proponho 4 camadas de avaliação. Cada uma responde a uma pergunta diferente:

### 1. Resultado (Outcome): "Funcionou?"

É a camada mais óbvia, mas também a mais traiçoeira se usada sozinha. Você define uma tarefa com critérios claros de sucesso, executa o agente, e verifica se o estado final está correto.

A pegadinha é que "correto" para um agente significa mais do que uma resposta textual bonita. Se seu agente deveria agendar uma reunião, o grader não pode apenas ler a mensagem de confirmação, ele precisa verificar se o evento _de fato_ apareceu no calendário, na data certa, com os participantes certos. A Anthropic chama isso de **verificação de estado**: checar o mundo real, não a narrativa do agente.

Métricas-chave nessa camada:

- **Task Success Rate**: percentual de tarefas completadas corretamente.
- **Grounding/Faithfulness**: as respostas são fiéis aos dados recuperados ou o agente inventou?
- **pass@k**: a probabilidade de que _pelo menos uma_ entre _k_ tentativas esteja correta. Útil para medir a capacidade bruta.
- **pass^k**: a probabilidade de sucesso em até _k_ tentativas sequenciais, parando na primeira correta. Modela a experiência real do usuário.

A diferença entre pass@1 (single-shot) e pass@k revela a _confiabilidade_ do agente. Um agente com pass@1 de 40% mas pass@5 de 90% é capaz, mas inconsistente. Você quer investir em torná-lo mais determinístico, não mais inteligente.

### 2. Trajetória (Trajectory): "Como chegou lá?"

Essa é a camada que separa avaliação amadora de avaliação profissional. Mesmo quando o resultado final está correto, o _caminho_ pode estar errado.

Um agente que resolve um bug de CSS pode ter lido 47 arquivos irrelevantes, tentado 12 edições fracassadas, e por sorte acertado na 13ª. O resultado é "correto", mas o processo é um desastre que custou 500 mil tokens. A avaliação de trajetória inspeciona cada passo do _trace_ (a sequência completa de observações, raciocínios, chamadas de ferramentas e resultados):

- **Seleção de ferramentas**: a ferramenta certa foi chamada?
- **Argumentos corretos**: os parâmetros passados fazem sentido?
- **Utilização dos resultados**: o agente usou a resposta da ferramenta adequadamente?
- **Recuperação de erros**: quando algo falhou, o agente se recuperou ou entrou em loop?
- **Coerência do plano**: a sequência de ações segue uma lógica progressiva?

Sem avaliação de trajetória, você não consegue distinguir competência de sorte. E sorte não escala.

### 3. Sistema: "Quanto custou?"

Se você leu meu post sobre [Tokenomics](/tokenomics-agentic-por-que-agentes-de-ia-estouram-sua-fatura-de-api/), sabe que o custo de agentes é estocástico e pode variar até 30x entre execuções da mesma tarefa. A camada de sistema trata o agente como qualquer outro serviço de produção:

- **Latência**: tempo total de execução (p50, p95, p99).
- **Custo por tarefa**: tokens consumidos × preço por token. Monitore a distribuição, não apenas a média.
- **Número de tool calls**: proxy poderoso para eficiência. Muitas chamadas podem indicar exploração ineficiente.
- **Robustez**: o agente se comporta bem quando uma API externa retorna erro 500? E quando o input do usuário é ambíguo ou malformado?

Essas métricas devem viver em dashboards, não em planilhas. E devem ter alertas.

### 4. Segurança e Confiança: "É seguro?"

A camada que ninguém quer fazer, mas que vai te salvar quando um agente alucinar dados de um cliente para outro ou ignorar uma política de compliance:

- **Aderência a políticas**: o agente respeitou limites de permissão, LGPD/GDPR, e regras de negócio?
- **Red teaming**: tentativas deliberadas de fazer o agente se comportar mal (prompt injection, jailbreaks).
- **Human-in-the-loop scoring**: revisão humana periódica de uma amostra de execuções para calibrar os graders automatizados.

## O padrão LLM-as-Judge

Uma das técnicas mais poderosas para avaliar agentes em escala é usar um LLM como juiz. Em vez de escrever heurísticas para cada cenário possível, você define um _rubric_ (critério de avaliação) e pede para um modelo forte (como GPT-5 ou Claude Opus) avaliar a resposta do seu agente.

O padrão funciona assim:

1. **Defina o rubric**: "Avalie de 1 a 5 se o agente respondeu corretamente, usando apenas as informações fornecidas, sem inventar dados."
2. **Forneça o contexto**: entrada do usuário, ferramentas disponíveis, resposta do agente.
3. **Colete o julgamento**: o LLM-juiz retorna uma nota e uma justificativa.

É escalável, consistente e surpreendentemente alinhado com julgamento humano quando bem calibrado. Mas tem armadilhas sérias:

| Vantagem | Armadilha correspondente |
| --- | --- |
| Escala para milhares de avaliações | Pode replicar vieses do modelo-juiz |
| Consistência na aplicação do rubric | Modelos podem alucinar justificativas |
| Custo menor que avaliação humana | Risco de _gaming_: agentes otimizados para agradar o juiz |
| Flexível para rubrics customizados | Requer calibração periódica com humanos |

A recomendação da Anthropic é usar uma abordagem **híbrida**: graders determinísticos (código) para verificações objetivas (o evento foi criado? o arquivo foi salvo?) e LLM-as-Judge para dimensões subjetivas (a resposta foi clara? o tom foi adequado?). Sempre com calibração humana periódica para garantir que o juiz ainda está alinhado com a realidade.

## Ferramental: de onde começar

O ecossistema de ferramentas de avaliação amadureceu significativamente. Aqui está um mapa pragmático:

**Para times code-first (Python/pytest):**
[DeepEval](https://github.com/confident-ai/deepeval) é a referência open-source. Oferece 50+ métricas prontas (faithfulness, hallucination, task completion, tool correctness), integração nativa com pytest, e suporte a traces multi-turn. Ideal para quem quer tratar evals como testes no CI.

**Para observabilidade e traces:**
[Langfuse](https://langfuse.com) é open-source e self-hostable. Excelente para quem precisa de soberania de dados e quer visualizar traces de agentes com dashboards. A profundidade de métricas é menor que o DeepEval, mas a combinação dos dois é poderosa.

**Para o ciclo completo (eval + monitoring + colaboração):**
[Braintrust](https://braintrust.dev) oferece um free tier generoso (1M spans/mês) e cobre desde avaliação pré-deploy até monitoramento em produção, com detecção automática de causa de falha em traces de agentes.

**Na prática, times maduros combinam pelo menos dois:**
- DeepEval para evals offline no CI + Langfuse para observabilidade em produção.
- Ou Braintrust como plataforma unificada + scripts customizados para domínios específicos.

## Um framework para começar do zero

Se você leu até aqui e está pensando "ok, mas por onde eu começo?", aqui vai um roteiro prático:

### Passo 1: Comece com 20 a 50 casos de teste

Não tente cobrir tudo. Selecione cenários reais que representem o uso mais comum e os edge cases mais perigosos do seu agente. Cada caso precisa de:

- **Input**: o que o usuário pede.
- **Contexto**: ferramentas disponíveis, dados acessíveis.
- **Critério de sucesso**: definição precisa e não ambígua do que "funcionar" significa.

### Passo 2: Automatize o grading

Para cada caso, defina um grader. Comece simples:

- **Determinístico**: o arquivo foi criado? O status HTTP retornado foi 200? O campo X no banco contém o valor Y?
- **LLM-as-Judge**: para dimensões mais subjetivas, configure um rubric com exemplos de nota alta e nota baixa.

### Passo 3: Execute com repetição

Lembre-se: agentes são estocásticos. Execute cada caso pelo menos 3 a 5 vezes. Registre pass@1 e pass@k. A variância entre execuções é um sinal tão importante quanto a média.

### Passo 4: Preserve os traces

Salve a trajetória completa de cada execução. Quando um eval falhar, o trace é sua ferramenta de debug. Sem ele, você está de volta ao mundo dos vibes: "acho que falhou por causa do prompt".

### Passo 5: Integre no CI/CD

Cada nova feature, mudança de prompt ou atualização de modelo deve passar pelos evals antes do merge. Falhas reais em produção devem se tornar novos casos de teste. Seu _eval suite_ é um organismo vivo, não um checklist estático.

### Passo 6: Monitore em produção

Evals pré-deploy não substituem observabilidade. Instrumente logs de custo, latência, taxa de sucesso e amostras de traces em produção. O drift acontece: o que funcionava com o modelo X pode degradar silenciosamente quando o provider atualiza para o modelo X.1.

## A disciplina que separa demos de produtos

Há uma frase do Hamel Husain que resume tudo:

> "Assim como na engenharia de software, o sucesso com IA depende de quão rápido você consegue iterar. E você não itera rápido sem evals."

Construir agentes é empolgante. Fazer demos que impressionam é fácil. Mas colocar um agente em produção e _saber_ que ele é confiável, eficiente e seguro? Isso exige a mesma disciplina que a engenharia de software levou décadas para desenvolver com testes automatizados.

A boa notícia é que você não precisa esperar décadas. O ferramental existe, os frameworks estão maduros, e o conhecimento está disponível. O que falta é a decisão de tratar avaliação como infraestrutura essencial, e não como um "nice to have" que a gente faz "quando sobrar tempo".

Se o seu agente não tem evals, ele não tem qualidade. Ele tem sorte. E sorte tem prazo de validade.
