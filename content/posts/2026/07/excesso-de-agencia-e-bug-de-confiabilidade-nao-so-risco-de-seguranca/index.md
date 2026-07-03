---
title: Excesso de agência é bug de confiabilidade, não só risco de segurança
description: "Quando um agente pode agir demais, o risco não é apenas vazamento ou abuso. Ele também fica ruim de operar: executa trabalho fora de escopo, repete ações, gasta orçamento e falha sem caminho claro de volta."
date: "2026-07-15T08:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - security
    - reliability
    - governance
url: /excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/
cover: cover.jpg
cover_alt: "Cadeado aberto sobre um teclado de computador."
cover_credit_name: "Sasun Bughdaryan"
cover_credit_url: "https://unsplash.com/@sasun1990"
---

Toda vez que falamos de excesso de agência em agentes de IA, a conversa cai rápido em segurança. Faz sentido. Um agente com ferramentas demais, permissões demais e autonomia demais vira um jeito elegante de transformar uma falha de prompt em uma ação real no mundo.

Mas olhar só por segurança deixa metade do problema fora da mesa.

Excesso de agência também é bug de confiabilidade. Mesmo quando não existe invasor, vazamento ou abuso deliberado, um agente com espaço de ação grande demais fica difícil de operar. Ele pode repetir uma ação, gastar orçamento sem perceber, alterar o recurso certo na hora errada, executar uma tarefa parecida com a que você pediu ou falhar no meio do caminho sem um estado recuperável.

Isso não é um detalhe de implementação. É uma fronteira de engenharia.

## O enquadramento de segurança é correto, mas incompleto

O OWASP Top 10 para aplicações com LLMs coloca excesso de agência como um risco explícito. A lista de 2025 ainda é a referência para aplicações LLM em geral, mas o material de 2026 do próprio OWASP abriu uma frente mais específica: o Top 10 para aplicações agênticas, focado em sistemas que planejam, usam ferramentas, carregam identidade e executam ações com algum grau de autonomia.

Essa atualização muda o centro da conversa. A questão deixa de ser apenas "o modelo gerou uma resposta perigosa?" e passa a incluir "o agente conseguiu transformar uma decisão ruim em efeito colateral?". É por isso que o material agêntico do OWASP fala de riscos ligados a objetivos desviados, ferramentas mal usadas, abuso de identidade ou privilégio, falhas em cascata, confiança humana mal calibrada e agentes que passam dos limites esperados.

A categoria LLM06:2025 continua útil porque nomeia a causa raiz de forma direta: funcionalidade excessiva, permissão excessiva ou autonomia excessiva. O Agentic Top 10 de 2026 deixa mais claro o que isso vira em sistemas reais.

Essa leitura é útil porque força uma pergunta que muita arquitetura de agente evita:

> O que esse sistema consegue fazer quando o modelo erra?

Não quando o atacante é genial. Não quando o prompt é obviamente malicioso. Quando o modelo simplesmente interpreta mal uma intenção, confia demais em uma observação ruim ou escolhe uma ferramenta que parecia razoável no contexto.

Esse é o ponto em que segurança e confiabilidade se encontram.

O próprio relatório de incidentes do OWASP para o primeiro trimestre de 2026 reforça esse ponto. Um dos casos descritos envolve um agente de email que deveria sugerir o que apagar ou arquivar, mas começou a deletar mensagens diretamente e ignorou comandos de parada enviados pelo celular. Não houve invasor externo. O problema foi mais básico: permissão destrutiva, confirmação fraca e caminho de recuperação ruim.

## Um agente seguro ainda pode ser pouco confiável

Imagine um agente interno de suporte. Ele autentica corretamente, usa credenciais válidas, só acessa APIs corporativas e nunca expõe dados fora da empresa. Do ponto de vista de segurança clássica, talvez ele pareça aceitável.

Agora dê a ele permissão para:

* ler tickets;
* editar status;
* aplicar créditos;
* alterar dados cadastrais;
* enviar respostas ao cliente;
* fechar atendimentos;
* repetir chamadas quando uma API falha.

Nenhuma dessas ações precisa ser maliciosa para causar problema.

O agente pode aplicar o crédito no cliente errado porque resumiu mal um ticket. Pode fechar uma fila inteira porque interpretou "resolver casos duplicados" como "fechar todos os casos parecidos". Pode tentar a mesma operação três vezes depois de um timeout e criar três efeitos colaterais. Pode passar por uma aprovação genérica no começo e depois executar uma sequência de ações que ninguém revisou de verdade.

Repare: nada disso exige jailbreak. O sistema pode estar autenticado, autorizado e ainda assim ser ruim de confiar.

O bug não é só "o agente pode ser atacado". O bug é "o agente pode agir mais do que o produto consegue absorver quando ele erra".

## Agência é parte do modelo de falha

Em software tradicional, costumamos modelar falhas em termos de exceções, timeouts, indisponibilidade e dados inválidos. Em agentes, existe uma falha adicional: a decisão plausível, mas errada.

O modelo escolhe uma ferramenta plausível. Os argumentos parecem coerentes. A resposta textual parece confiante. Só que a ação não deveria ter acontecido naquele contexto.

Se o sistema permite uma ação ampla, repetível e irreversível, você transformou uma incerteza probabilística em um incidente operacional. O problema deixou de ser "o modelo errou" e passou a ser "o ambiente aceitou o erro como comando executável".

Por isso eu prefiro tratar agência como uma dimensão explícita de confiabilidade:

* **Amplitude:** quantos tipos de ação o agente pode executar?
* **Frequência:** quantas vezes ele pode tentar antes de parar?
* **Escopo:** em quais recursos, contas, regiões ou clientes ele pode tocar?
* **Reversibilidade:** existe caminho de volta quando a ação foi errada?
* **Observabilidade:** alguém consegue reconstruir o que aconteceu sem depender da narrativa do agente?

Se essas perguntas não têm respostas claras, o agente não está pronto para produção. Ele pode até passar nos testes felizes, mas ainda não tem um modelo de execução confiável.

## O controle precisa estar fora do prompt

Uma resposta comum é tentar resolver isso com instrução:

> "Tenha cuidado antes de executar ações destrutivas."

Isso é melhor que nada, mas não é controle. É uma sugestão para o componente menos determinístico do sistema.

As fronteiras importantes precisam viver no harness, nas credenciais, nas APIs, no orquestrador e nos sistemas downstream. O prompt pode explicar a política. Ele não deve ser a política.

Na prática, isso significa desenhar o agente como qualquer outro sistema que executa efeitos colaterais.

### Permissões de ferramenta

Ferramentas devem ser estreitas. Um agente que precisa abrir um ticket não precisa de uma ferramenta genérica `call_http`. Ele precisa de `create_ticket` com schema pequeno, validação forte e comportamento previsível.

O mesmo vale para shell, banco de dados e cloud. Ferramentas abertas são confortáveis durante prototipação, mas criam uma superfície enorme de erro. Em produção, a pergunta deve ser: qual é a menor ação útil que posso expor?

### Credenciais escopadas

Não basta limitar a ferramenta se a credencial por trás dela continua ampla.

Use escopos mínimos, identidade do usuário quando fizer sentido, tokens de curta duração e permissões separadas para leitura e escrita. Um agente de recomendação que só precisa consultar produtos não deve carregar uma credencial que também atualiza preço.

Isso melhora segurança, claro. Mas melhora confiabilidade também, porque reduz o tamanho máximo do acidente.

### Dry-run como primeiro caminho

Para ações caras, destrutivas ou difíceis de reverter, o modo padrão deveria ser simular.

O agente monta o plano, calcula o diff, mostra quais recursos seriam alterados e só depois executa. Esse dry-run precisa ser produzido pelo sistema, não apenas descrito pelo modelo. Um plano textual bonito não substitui uma verificação real do estado.

### Aprovação no ponto certo

Human-in-the-loop só funciona quando a aprovação está perto do efeito colateral.

Aprovar "o agente pode resolver esse incidente" é amplo demais. Aprovar "escalar o deployment `checkout-api` de 8 para 12 réplicas no cluster `prod` pelos próximos 30 minutos" é muito melhor. A aprovação deve mostrar o alvo, a ação, o motivo, o diff e o caminho de rollback.

### Idempotência e deduplicação

Agentes repetem. APIs falham. Timeouts mentem.

Toda ação com efeito colateral deveria carregar uma chave de idempotência ou algum mecanismo equivalente. Se o agente tentar de novo, o sistema precisa saber se está repetindo a mesma intenção ou criando uma nova operação.

Sem isso, retry vira uma forma educada de duplicar problemas.

### Limites de orçamento

Orçamento não é só dinheiro. É tempo, chamadas de ferramenta, tokens, alterações por execução, itens processados e profundidade de loop.

Um agente confiável deve ter limites explícitos e comportamento decente quando eles são atingidos. Parar, explicar o estado atual e pedir intervenção é muito melhor do que continuar tentando até bater em um limite duro da plataforma.

### Trilha de auditoria

Depois de uma execução, você deveria conseguir responder sem adivinhação:

* quem pediu;
* qual era o objetivo;
* quais ferramentas foram chamadas;
* com quais argumentos;
* quais respostas voltaram;
* quais efeitos colaterais foram produzidos;
* quais aprovações existiram;
* qual rollback estava disponível.

Se a única explicação é um resumo gerado pelo próprio agente, você não tem auditoria. Você tem uma história.

### Caminho de rollback

Nem toda ação é reversível. Justamente por isso essa pergunta precisa aparecer antes do deploy.

Quando rollback não for possível, use compensação, snapshots, filas de revisão ou limites menores. O erro não é permitir ações irreversíveis. O erro é permitir ações irreversíveis com a mesma fricção de uma consulta read-only.

## A régua prática

Quando reviso o desenho de um agente, tento sair da discussão abstrata e perguntar coisas bem chatas:

1. O que ele consegue fazer sem aprovação?
2. Qual identidade aparece nos sistemas downstream?
3. Qual é o maior dano possível em uma única execução?
4. O que acontece se a mesma ação for repetida?
5. O que acontece se o modelo escolher a ferramenta certa com argumentos errados?
6. Existe dry-run para ações com efeito colateral?
7. Existe um limite claro de custo, tempo e número de tool calls?
8. Consigo reconstruir a execução a partir de logs estruturados?
9. Existe rollback ou compensação testada?
10. O agente falha parado ou falha agindo?

Essa última pergunta é a mais importante.

Sistemas confiáveis preferem parar quando não sabem. Sistemas com excesso de agência tendem a continuar, porque continuar parece progresso. Em agentes, essa diferença é enorme.

## Menos agência não é menos automação

Existe uma resistência emocional aqui. Muita gente interpreta limites como se fossem uma derrota: "se eu preciso aprovar tudo, então não tenho um agente".

Não é bem assim.

O objetivo não é transformar o agente em um formulário caro. O objetivo é dar autonomia onde o erro é barato e colocar fricção onde o erro é caro.

Um agente pode ler, classificar, resumir, propor, correlacionar e preparar mudanças com bastante liberdade. A fronteira muda quando ele vai alterar estado, gastar orçamento relevante, falar com cliente, apagar dado, mover dinheiro, mudar permissão ou mexer em produção.

Essa divisão parece burocracia até o dia em que você precisa explicar por que um modelo executou 200 ações corretas no formato e erradas na intenção.

## A pergunta certa

A pergunta "podemos confiar no modelo?" é ampla demais para ser útil.

A pergunta melhor é:

> O caminho de execução é estreito, observável e recuperável o suficiente para acomodar um modelo falível?

Se a resposta for não, você não tem apenas um risco de segurança. Você tem um bug de confiabilidade esperando uma entrada ruim, uma ambiguidade ou um retry infeliz.

Agentes bons não são os que podem fazer tudo. São os que conseguem fazer a coisa certa dentro de um espaço de ação bem desenhado, com limites que continuam funcionando quando o modelo erra.

## Referências

* [OWASP Top 10 for LLMs and Gen AI Apps 2025](https://genai.owasp.org/llm-top-10/)
* [OWASP LLM06:2025 Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/)
* [OWASP Top 10 for Agentic Applications for 2026](https://genai.owasp.org/initiatives/agentic-security-initiative/)
* [OWASP GenAI Exploit Round-up Report Q1 2026](https://genai.owasp.org/2026/04/14/owasp-genai-exploit-round-up-report-q1-2026/)
