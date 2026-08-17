---
title: "A produtividade da IA não é um número: por que os ganhos são reais, mas desiguais"
description: "Experimentos randomizados, estudos de campo e dados de empresas mostram que a IA aumenta a capacidade de desenvolvimento, mas nem sempre acelera a entrega."
date: "2026-08-17T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - software-development
    - developer-productivity
    - engineering
    - research
url: /produtividade-da-ia-ganhos-reais-mas-desiguais/
cover: cover.jpg
cover_alt: "Laptop azul com código aberto sobre uma mesa de trabalho."
cover_credit_name: "Bayu Syaits / Unsplash"
cover_credit_url: "https://unsplash.com/photos/laptop-and-phone-on-a-desk-with-coding-software-open-oYzjGQ7LCVE"
---

Quando alguém afirma que a inteligência artificial torna desenvolvedores 30% mais produtivos, a próxima pergunta deveria ser: **30% de quê?**

Tempo para concluir uma tarefa? Pull requests? Commits? Deploys? Valor entregue ao usuário? Satisfação do time? Cada métrica captura uma parte diferente do trabalho de engenharia.

A evidência disponível até agosto de 2026 sustenta uma conclusão mais interessante do que um multiplicador universal: **a IA aumenta a capacidade de produzir software, mas o ganho realizado depende da tarefa, do repositório, da experiência do desenvolvedor, do modo de uso da ferramenta e da capacidade de revisão do sistema**.

Os ganhos são reais. Eles também são distribuídos de forma desigual.

## Produtividade tem vários denominadores

Antes de comparar estudos, precisamos separar as perguntas que costumam ser misturadas:

| Medida | Pergunta que ela responde |
| --- | --- |
| Velocidade da tarefa | Quanto tempo levou para concluir o mesmo trabalho? |
| Throughput | Quantas tarefas, PRs ou commits foram produzidos? |
| Fluxo de entrega | Quanto tempo leva para uma mudança chegar ao usuário? |
| Qualidade e confiabilidade | Quanto retrabalho, falha, rollback ou incidente surgiu depois? |
| Valor | O software resolveu um problema importante para o usuário ou para o negócio? |
| Experiência do desenvolvedor | O time está mais focado, satisfeito e sustentável? |

Uma melhoria em uma linha não garante melhoria em todas as outras. É perfeitamente possível escrever código mais rápido, abrir mais PRs e ainda esperar mais tempo por revisão antes de fazer deploy.

## O que a pesquisa mede, de fato

Os resultados abaixo parecem divergentes porque medem populações e desfechos diferentes:

| Evidência | Resultado principal | Como interpretar |
| --- | --- | --- |
| Experimento controlado com GitHub Copilot | 55,8% menos tempo em uma tarefa de servidor HTTP em JavaScript ([estudo](https://arxiv.org/abs/2302.06590)) | Forte efeito em uma tarefa bem delimitada e autocontida. Não é uma medida do ciclo completo de produto. |
| RCT empresarial do Google | Aproximadamente 21% menos tempo em uma tarefa complexa de nível empresarial, com 96 engenheiros ([estudo](https://arxiv.org/abs/2410.12944)) | Evidência positiva em um ambiente real, mas com uma tarefa e ferramentas internas específicas. |
| Três experimentos de campo, publicados em *Management Science* | 26,08% mais tarefas concluídas entre 4.867 desenvolvedores ([estudo](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)) | A evidência causal mais ampla até agora. O efeito é ruidoso, mede principalmente acesso a completions e volume de output, e foi maior entre desenvolvedores menos experientes. |
| RCT da METR | Tarefas levaram 19% mais tempo para 16 desenvolvedores experientes em 246 tarefas de projetos maduros ([estudo](https://arxiv.org/abs/2507.09089)) | Um alerta causal importante sobre trabalho brownfield, contexto tácito e custo de validação. Não é uma taxa universal de impacto da IA. |
| Estudo de open source, versão revisada em agosto de 2026 | 5,9% mais contribuições de código, mas 8% mais tempo de coordenação ([estudo](https://arxiv.org/abs/2410.02091)) | Mais produção pode vir acompanhada de mais discussão, integração e coordenação. |
| Estudo longitudinal de uma empresa com meta de 2x | 2,09 vezes mais PRs por desenvolvedor ativo em abril de 2026, enquanto a carga de revisão aproximadamente dobrou ([estudo](https://arxiv.org/abs/2607.01904)) | Um sinal forte de que ganhos grandes são possíveis em uma organização favorável, mas o estudo não foi randomizado e cobre uma única empresa. |

O resultado mais importante não é escolher um número vencedor. É perceber que cada número estima um **efeito diferente**.

## 1. A IA é ótima em algumas tarefas e medíocre em outras

Os maiores ganhos aparecem quando o problema é bem especificado, local, testável e composto por padrões que o modelo já conhece. Criar um endpoint convencional, gerar testes, transformar estruturas de dados, produzir documentação inicial ou escrever código repetitivo são exemplos de trabalhos nos quais a velocidade bruta tende a aparecer.

Já tarefas ambíguas, arquiteturais ou dependentes de contexto histórico são outra história. Elas exigem entender contratos implícitos, decisões antigas, exceções de negócio e consequências que não estão escritas em um único arquivo.

É exatamente nesse cenário que o estudo da METR encontrou o slowdown. Os participantes trabalhavam em repositórios maduros que conheciam bem. Com a IA habilitada, passaram menos tempo codificando, mas mais tempo revisando a saída, escrevendo prompts, esperando e corrigindo mudanças. O modelo produzia texto rapidamente, mas não possuía todo o conhecimento tácito necessário para produzir uma mudança pronta para merge.

Uma forma simples de entender isso é pela ideia de gargalo. Se a codificação representa 40% de um ciclo de entrega e a IA torna essa parte 25% mais rápida, o ganho teórico no ciclo inteiro é de apenas 10%, antes de considerar retrabalho, revisão e incidentes. A conta é uma ilustração, não uma estimativa observada, mas mostra por que uma grande melhoria local pode virar uma pequena melhoria sistêmica.

## 2. Contexto é um multiplicador

Modelos podem ler arquivos, mas ler não é o mesmo que compreender o contexto operacional de um sistema.

Um repositório com documentação atualizada, testes confiáveis, CI rápido, arquitetura modular e feedback claro oferece ao modelo um ambiente onde erros são descobertos cedo. Um repositório com testes frágeis, serviços fortemente acoplados e regras espalhadas na memória de pessoas específicas transforma cada sugestão em uma investigação.

O estudo longitudinal da empresa com meta de 2x encontrou ganhos concentrados em código novo e quase ausentes em código legado. Essa diferença é coerente com a experiência da METR: quanto mais conhecimento tácito e compatibilidade histórica uma mudança exige, maior o custo de verificar se a geração realmente está correta.

É por isso que a IA funciona melhor como multiplicador de uma base de engenharia saudável. Ela não substitui documentação, testes ou observabilidade. Em muitos casos, torna a ausência deles mais cara.

## 3. O gargalo migra da geração para a revisão

O sistema de desenvolvimento tem uma capacidade limitada de revisar, integrar e operar mudanças. Se a IA aumenta a taxa de geração sem aumentar essa capacidade, a fila simplesmente aparece em outro lugar.

O DORA descreveu essa tensão em dois momentos. O relatório anterior sobre GenAI associou um aumento de 25% na adoção a uma queda de 1,5% no throughput de entrega e de 7,2% na estabilidade. A explicação proposta foi que a geração rápida favorece mudanças maiores, que demoram mais para revisar e têm maior probabilidade de instabilizar o sistema ([relatório DORA sobre GenAI](https://dora.dev/ai/gen-ai-report/report/)).

No relatório de 2025, baseado em quase 5.000 profissionais de tecnologia, a associação entre adoção de IA e throughput passou a ser positiva, mas a estabilidade continuou associada negativamente à adoção ([relatório DORA de 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)). Isso parece menos uma contradição do que um sinal de adaptação: as equipes aprenderam a absorver mais produção, mas a confiabilidade ainda exige investimento.

O estudo empresarial mais recente reforça a mesma leitura. A quantidade de PRs cresceu até 2,09 vezes, mas a carga por revisor também aproximadamente dobrou. A revisão automatizada passou a cobrir mais mudanças, enquanto as taxas de merge e revert permaneceram estáveis. A geração não eliminou o trabalho de revisão; ela reorganizou esse trabalho.

Há também um efeito coletivo. A versão mais recente do estudo sobre open source encontrou mais contribuições e mais participação, mas também 8% mais tempo de coordenação. Em uma comunidade, uma sugestão que economiza tempo para quem escreve pode criar discussão adicional para quem integra.

## 4. A experiência distribui o ganho de forma desigual

Os experimentos de campo publicados em *Management Science* encontraram maior adoção e ganhos maiores entre desenvolvedores menos experientes. Isso sugere que assistentes de código podem reduzir barreiras de entrada e ajudar pessoas a produzir em áreas nas quais ainda não dominam todos os padrões.

Mas a experiência tem um segundo efeito. Desenvolvedores seniores são justamente os mais capazes de identificar bugs sutis, violações arquiteturais e decisões frágeis. Em um estudo observacional recente sobre open source, contribuições de pessoas periféricas cresceram, enquanto mantenedores centrais passaram a revisar mais código e a produzir menos código original ([estudo sobre custo de manutenção](https://arxiv.org/abs/2510.10165)). Esse trabalho ainda é um preprint e usa uma identificação observacional, portanto deve ser lido como sinal, não como causalidade definitiva.

A pergunta não é apenas se cada desenvolvedor ficou mais rápido. É também: **quem absorveu o custo da velocidade?**

## 5. O baseline das ferramentas está mudando

Não devemos tratar o resultado de 19% de slowdown da METR como se fosse uma fotografia permanente da IA para programação. O estudo mediu ferramentas disponíveis entre fevereiro e junho de 2025, principalmente Cursor Pro e Claude 3.5/3.7 Sonnet.

Em uma atualização de fevereiro de 2026, a METR afirmou que as ferramentas mais novas provavelmente aceleram mais os desenvolvedores. Ao mesmo tempo, a organização considerou seu novo experimento inconclusivo: usuários que não queriam trabalhar sem IA deixaram de participar, alguns participantes mudaram o tipo de tarefa escolhida e o uso simultâneo de múltiplos agentes tornou a medição de tempo pouco confiável ([atualização da METR](https://metr.org/blog/2026-02-24-uplift-update/)).

Essa cautela é importante. O cenário atual mistura autocomplete, chat dentro da IDE, agentes que editam o repositório e agentes que executam tarefas em paralelo. Cada modo altera a distribuição do trabalho e a forma correta de medir tempo.

## 6. Velocidade percebida não é valor entregue

Uma pesquisa da METR com 349 profissionais técnicos no início de 2026 encontrou uma mediana de 1,4 a 2 vezes mais valor percebido no trabalho e 3 vezes mais velocidade percebida. Os próprios autores alertam que a amostra é de conveniência, teve resposta de aproximadamente 2% entre os contatos e pode superestimar ganhos. Eles também distinguem velocidade de valor: a IA pode tornar viável uma tarefa que antes nem seria priorizada, sem que isso signifique o dobro de valor para o produto ([pesquisa da METR](https://metr.org/blog/2026-05-11-ai-usage-survey/)).

O DORA encontrou algo complementar: usuários intensivos relatam mais flow, satisfação e produtividade, mas não necessariamente passam menos tempo em tarefas burocráticas. Um estudo longitudinal pequeno com três equipes ágeis observou aumento de performance e eficiência percebida com atividade praticamente estável, sugerindo maior densidade de valor, e não simplesmente mais volume ([estudo longitudinal sobre equipes ágeis](https://arxiv.org/abs/2602.13766)).

Isso muda a pergunta de gestão. Em vez de perguntar “quantas linhas ou PRs a IA adicionou?”, deveríamos perguntar “qual trabalho importante ficou possível, melhor ou mais rápido?”.

## Como medir na sua equipe

Uma avaliação séria precisa combinar métricas de geração com métricas de absorção:

1. **Segmente por tipo de tarefa.** Compare testes, documentação, manutenção, features novas, refatorações e mudanças arquiteturais separadamente.
2. **Meça o ciclo completo.** Registre tempo até merge, espera por revisão, rework, rollback e tempo até produção, não apenas tempo de digitação.
3. **Acompanhe a qualidade.** Observe falhas de mudança, defeitos escapados, incidentes, reversões e alterações que precisam ser reabertas.
4. **Meça a capacidade de revisão.** A IA pode melhorar o output individual enquanto aumenta a fila e a carga dos mantenedores.
5. **Inclua experiência e contexto.** Compare resultados por senioridade, familiaridade com o repositório, maturidade do código e modo de uso da ferramenta.
6. **Conecte a produtividade ao valor.** Use adoção de funcionalidades, tempo de resolução de problemas, satisfação do usuário e resultados de negócio quando fizer sentido.

Linhas de código, quantidade de PRs e taxa de sugestões aceitas podem ser sinais auxiliares. Sozinhos, são métricas fáceis de inflar e difíceis de relacionar com software melhor.

## A conclusão mais útil

A IA não é um multiplicador constante aplicado a todos os desenvolvedores e tarefas. Ela é um **amplificador com distribuição de efeitos**.

Os maiores ganhos aparecem quando o trabalho é bem especificado, testável e apoiado por bons fluxos de engenharia. Os menores ganhos, e às vezes perdas, aparecem quando o custo principal está em compreender contexto, validar comportamento, coordenar pessoas ou manter sistemas legados.

O futuro da produtividade em software não será decidido apenas pela velocidade de geração. Será decidido pela capacidade de especificar, revisar, integrar e operar o código produzido.

Os ganhos são reais. Para transformá-los em valor real, a equipe precisa aumentar a capacidade de verificação junto com a capacidade de geração.
