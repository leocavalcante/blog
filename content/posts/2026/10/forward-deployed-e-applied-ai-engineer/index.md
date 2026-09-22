---
title: "O que fazem o Forward Deployed Engineer e o Applied AI Engineer"
description: "Li cinco anúncios abertos em setembro de 2026 na Palantir, na OpenAI e na Anthropic. Eles descrevem o mesmo arco, do problema em aberto até adoção em produção, e cobram dois entregáveis: o sistema do cliente e o que ele ensina de volta para o produto."
date: "2026-10-05T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - evaluation
    - software-engineering
    - developer-experience
url: /forward-deployed-e-applied-ai-engineer/
cover: cover.jpg
cover_alt: "Cinco pessoas em volta de uma mesa de madeira, cada uma com um laptop aberto."
cover_credit_name: "Marvin Meyer"
cover_credit_url: "https://unsplash.com/photos/group-of-people-using-laptop-computer-QckxruozjRg"
---

A Palantir descreve o dia do Forward Deployed AI Engineer como o de um CTO hands-on de startup de IA: time pequeno, projeto de alto risco, entrega do começo ao fim junto com o cliente.

A OpenAI escreve, na vaga de Applied AI Engineer, que sucesso é sistema em produção e adoção sustentada, e não atividade ou demonstração bem-sucedida.

A Anthropic coloca workshop técnico e code review com o time de engenharia do cliente na lista de responsabilidades.

Os três estão contratando para o mesmo trecho de trabalho: pegar um modelo que já funciona e fazer ele funcionar dentro do sistema de outra pessoa.

**O trabalho desses cargos é levar o modelo da capacidade até a produção do cliente. E o entregável é duplo: o sistema que passa a rodar lá, e o que essa experiência devolve para o produto de quem vendeu o modelo.**

Li cinco páginas de vaga em setembro de 2026, duas da Palantir, duas da OpenAI e uma da Anthropic. Elas dizem o que cada empresa anuncia, não o que acontece depois que a pessoa entra. Todo o resto deste post sai desses textos.

## O arco começa antes de existir spec

Nenhum dos anúncios começa em requisito fechado.

A Palantir abre a [vaga de Forward Deployed Software Engineer](https://jobs.lever.co/palantir/5168e8fd-fec1-4fea-b7a1-81bdaea65850) com perguntas do tipo "como prever e reduzir risco de incêndio numa rede elétrica" e "como analisar e adaptar uma cadeia de suprimentos global para entregar peças críticas no prazo". O texto pede que o engenheiro fique com o problema até ele ser dele.

A OpenAI lista, no [Forward Deployed Engineer](https://openai.com/careers/forward-deployed-engineer-(fde)-sf-san-francisco/), a sequência inteira sob o mesmo dono: discovery, escopo técnico, desenho de sistema, build e rollout em produção.

Na [Applied AI Engineer, Enterprise](https://openai.com/careers/applied-ai-engineer-enterprise-san-francisco/), a cadeia aparece com os mesmos elos e um nome a mais no meio: seleção de caso de uso, arquitetura, prototipagem, avaliação, lançamento em produção e escala.

Na [Anthropic](https://www.anthropic.com/careers/jobs/5057647008), o engenheiro acompanha um portfólio de contas da descoberta técnica até o deploy, traduzindo requisito de negócio em solução técnica junto com o time de vendas e os Applied AI Architects.

O padrão é o mesmo nos quatro. A pessoa entra quando ainda não se sabe o que construir e sai quando aquilo está rodando com usuário em cima.

## O que essas pessoas constroem

A [vaga de Forward Deployed AI Engineer](https://jobs.lever.co/palantir/636fc05c-d348-4a06-be51-597cb9e07488) fala em construir workflows de LLM em escala e implantar a solução dentro da realidade da organização parceira. O anúncio de FDSE é mais concreto sobre o entorno: aplicações sob medida, workflows de LLM e soluções de produção desenhadas para a realidade daquele cliente, mais dados numa escala que quebra suposições.

A OpenAI detalha o que sai das mãos do Applied AI Engineer: protótipos, harness de avaliação, implementações de referência, integrações e aceleradores de produção. No FDE, a lista inclui sistemas full-stack e padrões codificados em ferramentas, playbooks ou blocos que outras pessoas reutilizam.

A Anthropic descreve pilotos customizados, protótipos e suítes de avaliação como a forma de influenciar a arquitetura e a estratégia de produto do cliente.

Repare no que aparece em todas as listas ao lado do código: avaliação. Não é um detalhe do final do projeto. Na OpenAI, ela está no meio da cadeia de entrega. Na Anthropic, é o artefato que sustenta a conversa de arquitetura.

## O que se espera de quem ocupa a cadeira

**Código na mão.** A OpenAI pede que o FDE escreva e revise código de produção em front e back, e que contribua direto no código quando o progresso depender disso. No Applied AI, exige contribuição pessoal em código, arquitetura, avaliação, debug ou engenharia de produção, e diz explicitamente que gestão de programa ou de stakeholder não basta. A Palantir pede proficiência em linguagem nas duas vagas. A Anthropic pede Python ou TypeScript com aplicação em produção.

**Avaliação como competência declarada.** A OpenAI espera avaliar sistemas de IA de forma sistemática, com dados representativos, graders, sinais de produção e julgamento humano. A Anthropic pede experiência de produção com LLM incluindo frameworks de avaliação e análise de transcript. A Palantir lista Evaluation como primeiro item dos fundamentos de Machine Learning que cobra do Forward Deployed AI Engineer.

**Tudo que cerca o modelo.** A OpenAI enumera as decisões do cargo: comportamento do modelo, confiabilidade, latência, custo, segurança, governança e prontidão operacional. Para o ambiente enterprise, acrescenta integrações, observabilidade, privacidade e governança de dados. A Palantir cobra do FDSE prática de desenvolvimento seguro, com gestão de vulnerabilidade, controle de acesso e privacidade.

**Conversa com a organização inteira.** A Palantir descreve donos de relacionamento que vão do usuário no chão de fábrica ao executivo que decide. A OpenAI diz que o time trabalha com executivos, times de produto e engenharia, líderes de segurança e times de transformação. A Anthropic inclui workshops e code review com a engenharia do cliente, além de conferências, palestras e publicação de posts e white papers.

**Ambiguidade como condição de trabalho.** A Palantir pede agência, decisão com informação incompleta e disposição de não operar dentro dos limites atuais do produto. A OpenAI pede escopo e entrega em ambientes que mudam, e julgamento sob pressão.

**Proximidade física ainda é parte do desenho.** O FDSE da Palantir espera 25% a 50% de viagem, o Forward Deployed AI Engineer até 25%, o FDE da OpenAI até 50%. A Anthropic fala em viagem ocasional. A Applied AI Engineer da OpenAI não cita viagem e sim três dias de escritório por semana.

A barra de entrada varia bastante. O FDSE pede seis meses de experiência depois da graduação. A Anthropic pede quatro anos ou mais. O FDE da OpenAI pede cinco anos ou mais, com trabalho voltado a cliente.

## O segundo entregável é o que explica o cargo na indústria

Quatro dos cinco anúncios pedem que a experiência de campo volte para dentro de casa.

A Palantir quer que o Forward Deployed AI Engineer devolva ao AIP o que aprendeu com o cliente. A OpenAI mede o FDE por feedback via eval que muda o roadmap de produto e de modelo, e descreve o time de Applied AI dizendo que transforma lição de deployment em produto melhor e em padrão reutilizável para outros clientes. A Anthropic pede que padrões comuns virem insight para Product e Engineering, e que o que se repete vire material interno ou público. O único que não menciona esse retorno é o FDSE, a única das cinco vagas sem IA no título.

Esse segundo entregável é a parte que eu acho mais interessante.

O texto da OpenAI para deployment enterprise diz onde mora a dificuldade: arquiteturas existentes, ambientes de dados diversos, requisitos de segurança e governança, múltiplos grupos de stakeholder e mudança organizacional. Nenhum desses itens é capacidade de modelo.

Quem vende modelo precisa de um instrumento para enxergar isso, e o instrumento é uma pessoa dentro do cliente, escrevendo código e eval, com canal aberto para o time de produto. É o que esses anúncios estão comprando.

Vale marcar o limite. Cinco páginas de vaga mostram o que a empresa quer atrair e como pretende medir. Elas não mostram quantas dessas contratações terminam em adoção, nem quanto do aprendizado de campo realmente muda um roadmap.

## Onde isso encosta em quem não trabalha numa lab

Eu trabalho em Developer Experience, não num laboratório de modelo. Não tenho cliente externo para embarcar.

Mesmo assim a função aparece sem o título. Quando um squad quer colocar um agente num fluxo de verdade, alguém precisa sentar com o time dono do problema e entender o dado sujo, a permissão, o SLA e o que o usuário faz quando o modelo erra. Esse alguém precisa sair de lá com eval e com um padrão que o próximo squad consiga copiar.

Já escrevi sobre [avaliar agente além do vibes check](/avaliando-agentes-de-ia-alem-do-vibes-check/) e sobre [o peso do harness](/por-que-sua-ia-falha-o-segredo-n-o-est-no-modelo-mas-no-agent-harness/). Ver avaliação escrita como requisito de contratação, em quatro anúncios de três empresas diferentes, é o sinal mais claro que encontrei de que essa parte deixou de ser opcional.

O nome do cargo é decisão de cada empresa. A pergunta que dá para responder dentro do time é outra.

> Quem, no seu time, responde pela adoção do agente três meses depois do go-live?

## Fontes

- [Palantir, Forward Deployed Software Engineer](https://jobs.lever.co/palantir/5168e8fd-fec1-4fea-b7a1-81bdaea65850)
- [Palantir, Forward Deployed AI Engineer](https://jobs.lever.co/palantir/636fc05c-d348-4a06-be51-597cb9e07488)
- [OpenAI, Forward Deployed Engineer (FDE), San Francisco](https://openai.com/careers/forward-deployed-engineer-(fde)-sf-san-francisco/)
- [OpenAI, Applied AI Engineer, Enterprise](https://openai.com/careers/applied-ai-engineer-enterprise-san-francisco/)
- [Anthropic, Applied AI Engineer, Enterprise Tech](https://www.anthropic.com/careers/jobs/5057647008)
