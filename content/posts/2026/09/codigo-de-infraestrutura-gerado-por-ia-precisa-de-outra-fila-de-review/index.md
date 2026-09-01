---
title: "Código de infraestrutura gerado por IA precisa de outra fila de review"
description: "Dockerfiles, pipelines e Terraform não são apenas mais um diff. Quando a IA gera código com acesso ao caminho de produção, o review precisa seguir o risco do arquivo."
date: "2026-09-01T11:56:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - security
    - devops
    - infrastructure-as-code
    - code-review
url: /codigo-de-infraestrutura-gerado-por-ia-precisa-de-outra-fila-de-review/
cover: cover.jpg
cover_alt: "Navio de carga, contêineres e guindastes em operação em um porto."
cover_credit_name: "Haris Illahi"
cover_credit_url: "https://unsplash.com/photos/container-ship-loading-with-cranes-and-forklift-at-port-Dzh-udFZXrA"
---

Um agente cria um endpoint e erra uma validação. O bug pode expor uma rota.

O mesmo agente altera um Dockerfile, uma GitHub Action ou um módulo Terraform. Agora ele pode mudar a imagem que roda em produção, entregar um segredo para código não confiável ou abrir uma porta para a internet.

Os dois resultados chegam como texto em um pull request. O risco não chega do mesmo tamanho.

Já escrevi que [commits estão escalando mais rápido que reviews](/quando-commits-escalam-mais-rapido-que-reviews/) e que CI verde não substitui entendimento. O problema fica mais sério quando tratamos infraestrutura gerada por IA como se fosse apenas outra pasta do repositório. Não é. Esses arquivos controlam o ambiente que compila, testa, publica e executa o restante do código.

Minha conclusão é simples: **código de infraestrutura gerado por IA precisa de outra fila de review**.

Não porque todo Dockerfile escrito por um modelo esteja errado. Nem porque infraestrutura escrita à mão seja segura. A diferença é o tamanho do efeito colateral. Quando um arquivo decide permissões, rede, credenciais ou deploy, o caminho de revisão precisa acompanhar esse poder.

## O número dos Dockerfiles é ruim, mas precisa ser lido direito

O relatório [*The Security Gap in AI-Generated Code*](https://www.ioactive.com/wp-content/uploads/2026/05/IOA-The-Security-Gap-in-AI-Generated-Code.pdf), publicado pela IOActive em 2026, avaliou 27 modelos e aplicações de geração de código. O estudo usou 730 prompts, 27 linguagens, 216 categorias de vulnerabilidade e 72 detectores automatizados.

Na análise por linguagem, 396 dos 405 Dockerfiles gerados acionaram pelo menos uma detecção de segurança. Isso dá 97,8%. Terraform chegou a 71,8%, com 310 de 432 amostras sinalizadas. Pipelines CI/CD ficaram vulneráveis em 63,9% dos 675 testes da categoria, segundo o relatório.

É um resultado forte. Também é fácil transformá-lo numa afirmação maior do que a pesquisa sustenta.

O estudo não observou 405 Dockerfiles reais em produção. Ele gerou amostras a partir de prompts controlados e as avaliou com análise estática. Um alerta de detector não equivale automaticamente a uma exploração confirmada. Os prompts de baseline também não mencionavam segurança, justamente para medir o comportamento padrão dos modelos.

Portanto, "97,8% dos Dockerfiles feitos por IA são exploráveis" seria uma leitura ruim. A leitura útil é outra: **naquele benchmark, quase nenhuma geração padrão de Dockerfile satisfez o conjunto de controles esperados pelos detectores**.

Isso basta para derrubar a ideia de que infraestrutura gerada pode entrar no fluxo normal só porque parece curta, familiar e funcional.

## Infraestrutura é código com uma alavanca maior

Um Dockerfile costuma ter poucas linhas. Uma GitHub Action pode caber numa tela. Um plano Terraform parece declarativo e organizado.

Essa aparência engana.

Uma linha `FROM` escolhe a base da cadeia de suprimentos. Um `USER` ausente decide se o processo roda como root. Um `COPY` amplo pode levar chaves, arquivos de configuração ou lixo do ambiente de build para a imagem final. Uma action referenciada por uma tag mutável pode mudar sem que o seu repositório mude.

No pipeline, a combinação errada é ainda pior. O evento `pull_request_target` pode rodar com token de escrita e acesso a segredos. Se o workflow fizer checkout de código não confiável e depois executar um script desse código, um pull request vira caminho para comprometer o repositório. A [documentação de segurança do GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use) trata esse caso como risco de tomada do repositório.

Terraform também não é só uma descrição bonita do estado desejado. Uma regra de ingresso `0.0.0.0/0`, um bucket público, uma role ampla ou um banco sem proteção adequada podem passar pela validação sintática e continuar sendo decisões de segurança ruins.

É por isso que `terraform validate` não resolve o problema. O comando verifica sintaxe, argumentos, nomes e tipos. Ele não prova que o plano deveria ser aplicado.

Código de aplicação normalmente implementa comportamento dentro do ambiente. Código de infraestrutura define partes do próprio ambiente e das permissões disponíveis. O segundo não é mais importante em qualquer situação, mas frequentemente tem um raio de dano maior.

## O modelo imita o exemplo que encontra

Modelos são bons em produzir o padrão mais provável. Segurança de infraestrutura costuma depender exatamente do que o exemplo curto deixa de fora.

O Dockerfile de tutorial usa uma tag simples porque quer ensinar `docker build`. O workflow de demonstração concede uma permissão ampla porque quer chegar ao deploy. O módulo Terraform de uma resposta antiga abre acesso temporário porque quer provar que a conexão funciona.

Cada exemplo pode fazer sentido dentro do texto que o acompanha. Depois de absorvido e recombinado, o contexto desaparece. Sobra um padrão que compila.

Isso ajuda a explicar por que pedir "crie um Dockerfile para esta aplicação" produz algo funcional antes de produzir algo endurecido. O modelo otimiza primeiro para completar a tarefa visível. Rodar sem root, fixar imagens por digest, separar estágios, limitar permissões e não carregar segredos são requisitos que precisam estar no contexto ou nos controles externos.

Mas também não compro a solução mágica de acrescentar "faça de forma segura" no final do prompt.

O próprio estudo da IOActive encontrou respostas diferentes entre famílias de modelos e níveis de instrução. Em algumas configurações, prompts de segurança ajudaram. Em outras, quase não mudaram o resultado ou pioraram a pontuação. Prompt é uma entrada útil. Não é uma política executável.

## A fila deve seguir o arquivo, não a declaração do autor

Rotular uma mudança como gerada por IA ajuda. Eu continuo defendendo esse metadado porque ele dá contexto ao revisor e pode ajudar numa investigação.

Só que provenance não pode ser o único gatilho.

O [AI Accountability Report de 2026 do GitLab](https://about.gitlab.com/press/releases/2026-06-23-gitlab-research-reveals-organizations-are-generating-ai-code-faster-than-they-can-control-it/) ouviu 1.528 desenvolvedores e compradores de tecnologia. Entre os respondentes, 43% disseram que não conseguem distinguir com confiança código gerado por IA de código escrito por uma pessoa. Dos que tiveram um incidente no último ano, 34% não conseguiram determinar se código gerado contribuiu para o problema.

Se o gate depende de alguém marcar honestamente "isto veio de IA", ele vai falhar por esquecimento, integração incompleta ou edição mista. Depois de cinco alterações humanas, quem decide se o arquivo ainda é "gerado"?

Prefiro uma regra menos elegante e mais confiável: **o caminho do arquivo define o nível mínimo de revisão**.

Mudou `Dockerfile`, `.github/workflows/`, `terraform/`, Helm, Kubernetes, política IAM ou configuração de deploy? O pull request entra na fila de infraestrutura e segurança, tenha sido escrito por um agente, por uma pessoa ou pelos dois.

Provenance acrescenta contexto. O path determina o controle.

## Como eu montaria essa fila

Outra fila não precisa significar um comitê esperando reunião. Significa um conjunto diferente de donos, verificações e evidências.

### Ownership explícito

Arquivos de infraestrutura precisam de responsáveis claros. `CODEOWNERS` pode exigir revisão do time de plataforma ou segurança para diretórios críticos. A regra deve valer para qualquer autor e não pode ser removida pelo mesmo PR que tenta contorná-la.

### Diff do efeito, não só do texto

Para Terraform, quero ver o plano, não apenas o HCL. Para Kubernetes, quero o manifesto renderizado. Para políticas, quero saber quais ações e recursos foram adicionados. Para uma imagem, quero a lista de pacotes, usuário efetivo, base resolvida e resultado do scanner.

O revisor precisa enxergar o que mudará no sistema.

### Gates específicos

Cada tipo de arquivo pede verificações próprias:

- Dockerfile: imagem base aprovada e fixada, build em múltiplos estágios quando fizer sentido, usuário não-root, nenhum segredo em layer e scanner de imagem;
- CI/CD: actions fixadas por SHA completo, permissões mínimas para o token, nenhuma execução de código não confiável em contexto privilegiado e segredos limitados;
- Terraform: `fmt`, `validate`, plano, scanner de configuração, política sobre o plano e aprovação separada antes de `apply`;
- Kubernetes e Helm: manifests renderizados, políticas de admissão, limites de recursos, contexto de segurança e nenhuma credencial em texto aberto.

A [documentação do Docker](https://docs.docker.com/build/building/best-practices/) recomenda fixar imagens por digest para garantir a mesma base, usar múltiplos estágios para deixar ferramentas de build fora da imagem final e trocar para um usuário sem privilégio quando o serviço não precisa rodar como root.

No GitHub Actions, fixar uma action por SHA completo é a única forma documentada de tratá-la como release imutável. Para Terraform, [run tasks](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks) podem avaliar o plano antes do `apply` e bloquear a execução quando uma política obrigatória falha.

Não existe um scanner universal. O valor está em empilhar verificações que conhecem o tipo de efeito produzido.

### Template antes de geração livre

Para caminhos sensíveis, prefiro que o agente adapte um template validado em vez de começar de uma página vazia.

Uma organização provavelmente já sabe quais imagens base aceita, como injeta segredos, quais regiões usa, como configura logs e quais módulos Terraform foram aprovados. Transformar essas escolhas em módulos, actions reutilizáveis e imagens base reduz o espaço em que o modelo precisa improvisar.

O agente continua útil. Ele preenche variáveis, conecta módulos, atualiza versões e explica o diff. Só deixa de reinventar a fronteira de segurança a cada prompt.

### Aprovação perto do efeito

Merge e deploy não precisam ser a mesma permissão.

Uma pessoa pode aprovar a estrutura do código. Outra pode aprovar o plano contra o ambiente. O `apply` de produção pode exigir identidade separada, janela adequada e evidência de que o artefato revisado é exatamente o que será executado.

Esse ponto importa porque um PR seguro pode virar um deploy inseguro se a pipeline recalcular dependências mutáveis, puxar outra imagem ou executar com credenciais mais amplas do que as usadas no teste.

## IA pode ajudar no review, mas não pode atestar a si mesma

Um segundo agente pode procurar `USER` ausente, action sem SHA, permissão ampla ou porta aberta. Isso é útil. Um agente especializado pode até explicar o plano e destacar as mudanças com maior raio de dano.

Mas "um modelo escreveu e outro modelo aprovou" não cria independência suficiente.

Os dois podem compartilhar os mesmos exemplos inseguros, ignorar a mesma regra tácita ou ser convencidos pela mesma configuração plausível. A validação mais forte vem de fontes diferentes: parser, policy engine, scanner, ambiente efêmero, teste de integração e julgamento humano.

Use IA para reduzir o trabalho mecânico da revisão. Não use uma segunda resposta probabilística como certificado de segurança da primeira.

## A mudança de hábito

O erro não está em deixar um agente editar infraestrutura. Eu uso agentes justamente porque eles conseguem atravessar aplicação, testes, automação e documentação sem perder o objetivo da tarefa.

O erro é deixar essa fluidez apagar fronteiras que continuam importantes.

Um diff pequeno pode controlar uma credencial poderosa. Uma configuração legível pode criar um recurso público. Um pipeline verde pode ter acabado de executar código não confiável com acesso de escrita.

Por isso, a pergunta na revisão não deveria ser apenas "este código foi gerado por IA?".

Pergunte:

> Se este arquivo estiver errado, até onde o erro consegue chegar?

Quando a resposta inclui cadeia de suprimentos, credenciais, rede ou produção, o pull request precisa de outra fila. Não uma fila mais lenta por princípio. Uma fila que olha o efeito certo, exige a evidência certa e impede que a facilidade de gerar infraestrutura seja confundida com a segurança de operá-la.

## Fontes

- [The Security Gap in AI-Generated Code, IOActive](https://www.ioactive.com/wp-content/uploads/2026/05/IOA-The-Security-Gap-in-AI-Generated-Code.pdf)
- [The Security Gap in AI-Generated Code, resumo da IOActive](https://www.ioactive.com/the-security-gap-in-ai-generated-code/)
- [GitLab Research Reveals Organizations Are Generating AI Code Faster Than They Can Control It](https://about.gitlab.com/press/releases/2026-06-23-gitlab-research-reveals-organizations-are-generating-ai-code-faster-than-they-can-control-it/)
- [Docker build best practices](https://docs.docker.com/build/building/best-practices/)
- [Multi-stage builds, Docker Docs](https://docs.docker.com/build/building/multi-stage/)
- [Secure use reference, GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [Securely using `pull_request_target`, GitHub Actions](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target)
- [Format and validate Terraform configuration using the Terraform CLI](https://developer.hashicorp.com/terraform/cli/code)
- [HCP Terraform run tasks](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks)
