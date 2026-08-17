---
title: "A produtividade da IA não é um número: por que os ganhos são reais, mas desiguais"
description: "A IA escreve código mais rápido. A pergunta difícil é se ficou mais fácil entregar software que alguém consegue entender, revisar e manter."
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

A conversa sobre produtividade com IA está presa em um número.

55,8%. 26%. 19%.

Escolha o percentual que combina com a sua tese e você já tem um slide pronto para a próxima reunião. O problema é que software não é slide. O número pode estar correto e ainda assim contar só uma parte da história.

Se você acompanha meus textos sobre [commits e reviews](/quando-commits-escalam-mais-rapido-que-reviews/) e sobre [o próximo salto do desenvolvimento com IA](/o-proximo-salto-do-desenvolvimento-com-ia-da-assistencia-a-orquestracao/), sabe que eu não compro a ideia de que produtividade é simplesmente gerar mais código por hora.

A IA ficou muito boa em produzir código. A pergunta difícil é se ficou mais fácil produzir software.

Minha leitura da pesquisa até agosto de 2026 é direta: **os ganhos existem, mas não são um multiplicador universal. Eles dependem da tarefa, do repositório, da experiência do desenvolvedor, do tipo de ferramenta e da capacidade de revisão do time**.

## Primeiro: 30% de quê?

Antes de comparar os estudos, precisamos parar de misturar métricas diferentes na mesma frase:

| Métrica | O que ela mede |
| --- | --- |
| Velocidade da tarefa | Quanto tempo levou para fazer o mesmo trabalho? |
| Throughput | Quantas tarefas, PRs ou commits foram produzidos? |
| Fluxo de entrega | Quanto tempo leva para uma mudança chegar ao usuário? |
| Qualidade | Quanto retrabalho, rollback, bug ou incidente apareceu depois? |
| Valor | O software resolveu um problema importante? |
| Experiência | O time está mais focado e sustentável? |

Uma métrica pode melhorar enquanto outra piora. Dá para escrever código mais rápido, abrir mais PRs e esperar mais tempo por review antes do deploy. Dá para sentir mais flow e continuar gastando as mesmas horas em reunião, burocracia e coordenação.

É aí que começa a confusão.

## Os números não estão brigando

Os resultados abaixo parecem contraditórios porque respondem a perguntas diferentes:

| Estudo | Resultado | O que eu tiraria dele |
| --- | --- | --- |
| Experimento controlado com GitHub Copilot | 55,8% menos tempo em uma tarefa de servidor HTTP em JavaScript ([estudo](https://arxiv.org/abs/2302.06590)) | Tarefa pequena, bem delimitada e autocontida pode ficar muito mais rápida. Isso não é o ciclo completo de produto. |
| RCT empresarial do Google | Cerca de 21% menos tempo em uma tarefa complexa, com 96 engenheiros ([estudo](https://arxiv.org/abs/2410.12944)) | Existe ganho em ambiente real, mas uma tarefa e ferramentas internas não representam todo o mercado. |
| Três experimentos de campo publicados em *Management Science* | 26,08% mais tarefas concluídas entre 4.867 desenvolvedores ([estudo](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)) | É a evidência causal mais ampla até agora. Mede output de desenvolvimento e o efeito foi maior entre pessoas menos experientes. |
| RCT da METR | Tarefas levaram 19% mais tempo para 16 desenvolvedores experientes em 246 tarefas de projetos maduros ([estudo](https://arxiv.org/abs/2507.09089)) | Trabalho brownfield, contexto tácito e validação podem apagar o ganho ou virar slowdown. |
| Estudo de open source, revisado em agosto de 2026 | 5,9% mais contribuições de código, mas 8% mais tempo de coordenação ([estudo](https://arxiv.org/abs/2410.02091)) | Mais produção não significa coordenação grátis. |
| Estudo longitudinal de uma empresa com meta de 2x | 2,09 vezes mais PRs por desenvolvedor ativo, enquanto a carga de review aproximadamente dobrou ([estudo](https://arxiv.org/abs/2607.01904)) | Ganhos grandes são possíveis, mas esse é um caso não randomizado e muito favorável à IA. |

Não dá para escolher um número e chamar isso de “a produtividade da IA”. Cada estudo está estimando uma coisa.

## 1. A mágica aparece em tarefas bem definidas

Os maiores ganhos aparecem quando o problema é local, testável e baseado em padrões conhecidos. Criar um endpoint convencional, gerar testes, transformar uma estrutura de dados, escrever documentação inicial ou produzir código repetitivo são trabalhos em que a velocidade bruta aparece com facilidade.

A tarefa do experimento do Copilot era um servidor HTTP em JavaScript. O resultado de 55,8% é relevante. Também é exatamente o tipo de número que vira propaganda quando alguém esquece de dizer o que foi medido.

O mundo real tem uma parte menos conveniente. Tarefas de arquitetura, regras de negócio, segurança, performance e manutenção de sistemas antigos não vêm com um enunciado limpo e um conjunto de testes perfeito. Elas exigem entender por que aquele código estranho existe, qual cliente depende daquela exceção e qual comportamento não pode ser quebrado.

Foi nesse ambiente que a METR encontrou slowdown. Com a IA habilitada, os desenvolvedores passaram menos tempo codificando, mas mais tempo revisando a saída, escrevendo prompts, esperando e corrigindo mudanças. O código apareceu rápido. O entendimento não.

Existe um gargalo simples aqui. Se a codificação representa 40% de um ciclo de entrega e a IA deixa essa parte 25% mais rápida, o ganho teórico no ciclo inteiro é de 10%, antes de considerar review, retrabalho e incidentes. É uma conta ilustrativa, não uma estimativa observada, mas ajuda a explicar por que uma melhoria enorme na geração pode virar uma melhoria pequena na entrega.

## 2. Contexto é o multiplicador que ninguém coloca no slide

Um modelo consegue ler arquivos. Isso não significa que ele sabe por que aquele código foi escrito daquele jeito.

Um repositório com documentação atualizada, testes confiáveis, CI rápido, arquitetura modular e feedback claro dá ao agente uma chance razoável de descobrir seus próprios erros. Um repositório com testes frágeis, serviços acoplados e regras guardadas na cabeça de três pessoas transforma cada sugestão em uma investigação.

O estudo longitudinal da empresa com meta de 2x encontrou ganhos concentrados em código novo e quase ausentes em código legado. Isso combina com a experiência da METR: quanto mais conhecimento tácito e compatibilidade histórica uma mudança exige, mais caro fica verificar se a geração está realmente correta.

É por isso que eu vejo IA como multiplicador de uma base de engenharia saudável. Ela não substitui documentação, testes ou observabilidade. Em muitos casos, torna a ausência deles mais cara.

## 3. A geração acelera. O review continua humano.

Escrever código ficou mais barato. Entender código não ficou.

Um agente pode abrir um PR em minutos. Isso não significa que alguém consiga entender aquele PR em minutos. Review ainda exige reconstruir contexto, comparar alternativas, identificar risco, checar testes e decidir se a mudança deveria existir.

Como escrevi em [Quando commits escalam mais rápido que reviews](/quando-commits-escalam-mais-rapido-que-reviews/), o custo caro do review nunca foi ler caracteres. Foi formar julgamento.

O DORA encontrou essa tensão em momentos diferentes. O relatório anterior sobre GenAI associou um aumento de 25% na adoção a uma queda de 1,5% no throughput de entrega e de 7,2% na estabilidade. A explicação é bastante plausível: a geração rápida favorece mudanças maiores, que demoram mais para revisar e têm mais chance de instabilizar o sistema ([relatório DORA sobre GenAI](https://dora.dev/ai/gen-ai-report/report/)).

No relatório de 2025, baseado em quase 5.000 profissionais de tecnologia, a associação entre adoção de IA e throughput passou a ser positiva, mas a estabilidade continuou associada negativamente ([relatório DORA de 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)). As equipes aprenderam a absorver mais output. A confiabilidade ainda cobra investimento.

O estudo empresarial mais recente conta a mesma história de outro jeito: PRs cresceram 2,09 vezes, mas a carga por revisor também aproximadamente dobrou. A revisão automatizada cobriu mais mudanças. O trabalho de review não desapareceu; ele mudou de lugar.

E no open source, o efeito aparece como coordenação: mais contribuições, mais participação e 8% mais tempo conversando e integrando. Uma sugestão pode economizar tempo para quem escreve e criar trabalho adicional para quem mantém.

## 4. A velocidade não fica distribuída igualmente

Os experimentos de campo publicados em *Management Science* encontraram maior adoção e ganhos maiores entre desenvolvedores menos experientes. Isso faz sentido: um assistente de código reduz a barreira para produzir algo que a pessoa ainda não escreveria sozinha.

Mas existe o outro lado. O desenvolvedor sênior é quem percebe o bug sutil, a violação arquitetural e a abstração que parece elegante mas vai custar caro daqui a seis meses.

Um estudo observacional recente sobre open source encontrou mais contribuições de pessoas periféricas, enquanto mantenedores centrais passaram a revisar mais código e a produzir menos código original ([estudo sobre custo de manutenção](https://arxiv.org/abs/2510.10165)). O trabalho ainda é um preprint e não prova causalidade sozinho. Mesmo assim, aponta para uma pergunta que quase nunca aparece no slide de produtividade:

**Quem absorveu o custo da velocidade?**

Se juniors geram mais e seniors passam o dia corrigindo, o time não ganhou apenas produtividade. Ele redistribuiu trabalho e risco.

## 5. As ferramentas estão mudando, então o baseline também

Eu não usaria o slowdown de 19% da METR como se fosse uma fotografia permanente da programação com IA. O estudo mediu ferramentas disponíveis entre fevereiro e junho de 2025, principalmente Cursor Pro e Claude 3.5/3.7 Sonnet.

Em fevereiro de 2026, a METR disse que as ferramentas novas provavelmente aceleram mais os desenvolvedores. Mas também disse que seu experimento mais recente era inconclusivo: pessoas que não queriam trabalhar sem IA deixaram de participar, algumas escolheram tarefas diferentes e o uso de múltiplos agentes tornou a medição de tempo pouco confiável ([atualização da METR](https://metr.org/blog/2026-02-24-uplift-update/)).

Essa cautela é importante. Hoje misturamos autocomplete, chat dentro da IDE, agentes que editam o repositório e agentes que trabalham em paralelo. Cada modo muda a distribuição do trabalho e muda a forma correta de medir tempo.

O que eu não faria é trocar um número antigo por uma promessa nova de 2x sem medir o próprio fluxo.

## 6. Mais rápido não é a mesma coisa que mais valor

Uma pesquisa da METR com 349 profissionais técnicos no início de 2026 encontrou mediana de 1,4 a 2 vezes mais valor percebido e 3 vezes mais velocidade percebida. Os próprios autores alertam que a amostra é de conveniência, teve resposta de aproximadamente 2% entre os contatos e pode superestimar ganhos ([pesquisa da METR](https://metr.org/blog/2026-05-11-ai-usage-survey/)).

Eles fazem uma distinção que eu considero essencial: velocidade e valor não são a mesma coisa. A IA pode tornar viável uma tarefa que antes nem entraria no backlog. Isso é útil. Não significa automaticamente que o produto ganhou o dobro de valor.

O DORA encontrou algo complementar: usuários intensivos relatam mais flow, satisfação e produtividade, mas não necessariamente gastam menos tempo em burocracia. Um estudo longitudinal pequeno com três equipes ágeis encontrou mais performance e eficiência percebida com atividade praticamente estável, sugerindo maior densidade de valor, e não simplesmente mais volume ([estudo longitudinal sobre equipes ágeis](https://arxiv.org/abs/2602.13766)).

A pergunta de gestão deixa de ser “quantas linhas a IA escreveu?” e passa a ser: **qual trabalho importante ficou possível, melhor ou mais rápido?**

## Como eu mediria isso em um time

Eu começaria por uma regra simples: não medir IA com uma única métrica.

1. **Separaria por tipo de tarefa.** Teste, documentação, manutenção, feature nova, refatoração e arquitetura não são a mesma coisa.
2. **Mediria o ciclo completo.** Tempo até merge, espera por review, rework, rollback e tempo até produção importam mais do que tempo de digitação.
3. **Acompanharia a qualidade.** Falha de mudança, bug escapado, incidente, revert e PR reaberto precisam entrar na conta.
4. **Mediria a carga de review.** Se output sobe e a fila de review explode, existe um problema, mesmo que o dashboard de commits esteja bonito.
5. **Segmentaria por contexto.** Senioridade, familiaridade com o repositório, maturidade do código e modo de uso da ferramenta mudam o resultado.
6. **Ligaria produtividade a valor.** Adoção da funcionalidade, tempo para resolver problemas, satisfação do usuário e resultado do negócio são sinais melhores do que linhas de código.

Linhas de código, quantidade de PRs e taxa de sugestões aceitas podem ajudar como sinais auxiliares. Sozinhas, são fáceis de inflar e difíceis de relacionar com software melhor.

## A conclusão que eu consigo defender

A IA não é um multiplicador constante aplicado a todos os desenvolvedores e tarefas. Ela é um **amplificador com uma distribuição de efeitos**.

Para uma tarefa clara, local e testável, o ganho pode ser enorme. Para um sistema legado, cheio de contexto tácito e revisão difícil, o ganho pode evaporar. Em alguns casos, a ferramenta apenas acelera a produção do trabalho que outra pessoa terá de entender e corrigir.

O futuro da produtividade em software não vai ser decidido apenas pela velocidade de geração. Vai ser decidido pela capacidade de especificar, revisar, integrar e operar o código produzido.

Os ganhos são reais. O atalho não é gratuito.

Se seu time está produzindo mais código, a pergunta seguinte é inevitável: vocês também conseguem entender e manter tudo isso?

## Referências

- [The Impact of AI on Developer Productivity: Evidence from GitHub Copilot](https://arxiv.org/abs/2302.06590)
- [How much does AI impact development speed?](https://arxiv.org/abs/2410.12944)
- [The Effects of Generative AI on High-Skilled Work](https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2025.00535)
- [Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity](https://arxiv.org/abs/2507.09089)
- [The Impact of Generative AI on Collaborative Open-Source Software Development](https://arxiv.org/abs/2410.02091)
- [AI Writes Faster Than Humans Can Review](https://arxiv.org/abs/2607.01904)
- [Impact of Generative AI in Software Development](https://dora.dev/ai/gen-ai-report/report/)
- [State of AI-assisted Software Development 2025](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)
- [METR productivity experiment update](https://metr.org/blog/2026-02-24-uplift-update/)
- [METR early-2026 AI usage survey](https://metr.org/blog/2026-05-11-ai-usage-survey/)
