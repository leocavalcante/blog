---
title: "Deixei dois agentes Pi mantendo meus repositórios. Eles inventaram o próprio trabalho"
description: "O Pi Durable manteve dois mantenedores autônomos trabalhando por quatro dias, inclusive durante uma atualização do próprio Pi. Sem demanda real, eles escreveram as próprias issues e mergearam 693 pull requests."
date: "2026-10-13T15:45:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - agent
    - llm
    - reliability
    - security
    - tooling
    - code-review
url: /deixei-dois-agentes-pi-mantendo-meus-repositorios/
cover: cover.jpg
cover_alt: "Fachada de um prédio de escritórios à noite, com dezenas de janelas acesas em tons de verde e salas quase vazias."
cover_credit_name: "Yury Orlov"
cover_credit_url: "https://unsplash.com/photos/a-very-tall-building-with-lots-of-windows-at-night-CJvWIcnvrXI"
---

Na sexta, 9 de outubro, por volta das 11h, liguei no meu home lab dois agentes autônomos para manter duas extensões do Pi que eu escrevi, o pi-subagents e o pi-tmux. Desliguei os dois na terça, pouco depois do meio-dia. Nesse intervalo, eles mergearam 693 pull requests, 378 deles no sábado e no domingo.

Cada PR foi aberto e mergeado pelo próprio agente, sem review humano. Entre abrir e mergear, a mediana ficou em 2 minutos no pi-tmux e em 6 no pi-subagents. No mesmo período, os dois repositórios receberam 664 issues novas. Com os filtros que consegui montar, só nove vieram do meu uso real das extensões.

Na sexta de manhã, o pi-tmux, que dá nome às janelas do tmux a partir da tarefa em andamento, tinha 738 linhas de código fora dos testes. Na terça, só o arquivo que monta, filtra e valida o pedido ao modelo de nomes tinha 4.364.

**O Pi Durable cumpriu a parte dele: os agentes atravessaram restarts e uma atualização do próprio Pi sem perder a sessão em andamento. O que deu errado estava no código que eu escrevi em volta da biblioteca. O loop não tinha outra fonte de trabalho além do próprio agente, não tinha um estado para "nada a fazer", e a única fronteira que mantive dependia de uma lista de formatos.**

Os números saem dos dois repositórios, que são públicos, e do diário de sessões dos agentes. Contei de sexta, às 11h, até o último merge dos agentes, na terça, às 12h22, horário de Brasília. As contagens de linha incluem comentários e linhas em branco.

## O Pi deixa de fora o que você pode construir

O README descreve o Pi como um harness de agente mínimo e extensível, para você adaptar ao seu fluxo de trabalho, e não o contrário. Mario Zechner começou o projeto e, num post de novembro de 2025, resumiu a regra: se ele não precisa de uma coisa, ela não é construída.

O Pi é enxuto de propósito. As ferramentas padrão são quatro: `read`, `write`, `edit` e `bash`. Naquele post, Mario contava menos de 1.000 tokens para o system prompt e as definições de ferramenta somados. O Pi também não pede aprovação antes de cada chamada de ferramenta. A documentação de segurança diz que a proteção vem de limitar os arquivos, as credenciais, os processos e a rede que o processo alcança, e que acompanhar o transcript não cria fronteira de segurança.

O README lista o que fica de fora, como subagentes e plan mode, e sugere pedir ao próprio Pi para construir o que falta ou instalar um pacote que faça do seu jeito. Extensões são módulos TypeScript carregados no processo do Pi e registram ferramentas, comandos, atalhos, providers e componentes de interface no terminal. O mesmo agente roda no modo interativo, em print ou JSON, por RPC ou dentro de uma aplicação, pelo SDK.

O Pi 1.0 saiu em 1º de outubro de 2026, lançado pela Earendil e pela comunidade do Pi. Minhas duas extensões nasceram nos dias seguintes, no espaço que o core deixa aberto.

O pi-subagents delega tarefas a agentes Pi isolados, um de cada vez, em paralelo ou em cadeia. Em 2025, a sugestão do Mario para subagentes era o Pi chamar a si mesmo pelo bash, ou até dentro de uma sessão do tmux, para acompanhar e interagir com o subagente. A extensão transforma esse padrão em ferramenta. O pi-tmux dá nome à janela do tmux a partir da tarefa e do histórico da sessão, e marca as janelas que estão esperando input.

## O Pi Durable grava cada passo antes de dar o próximo

O Pi Durable saiu junto com o Pi 1.0, como pacote experimental. O anúncio da Earendil explica por que ele existe. O Pi foi feito para rodar num terminal, conduzido por uma pessoa. Se o processo morre, essa pessoa olha o que aconteceu e manda continuar. O Pi Durable é um framework para aplicações agênticas que rodam por muito tempo, em qualquer lugar, sobrevivem a falhas e aceitam mais de uma pessoa conduzindo os mesmos agentes.

Para a Earendil, um harness é storage mais a maquinaria que roda conversas com modelos, as ferramentas que eles chamam e os ambientes onde essas ferramentas executam. Tudo o que o harness executa é uma task, da chamada ao modelo à execução de uma ferramenta. Cada task grava um checkpoint antes de seguir. Se o processo morre, outro processo abre o mesmo storage, encontra as tasks pela metade e continua cada uma do último checkpoint.

Depois de um crash, o Pi Durable separa o que pode ser repetido do que não pode. Uma chamada ao modelo interrompida é reenviada, e a resposta parcial fica no transcript, marcada como abortada. Uma ferramenta interrompida só roda de novo se declarar que é segura para repetir. Se não declarar, o modelo recebe a chamada como interrompida, com a saída gravada até ali, e decide o que fazer. Nos meus agentes, um `bash` interrompido voltava assim, e o agente conferia de novo o git e o GitHub antes de seguir.

A compactação também é uma task e roda em background. Quando o contexto chega perto do limite do modelo, um resumo substitui as mensagens antigas nos próximos pedidos, sem apagar nada do storage. Segundo o anúncio, o pacote inteiro tem cerca de 15 mil linhas, sem contar os testes.

O loop dos meus agentes, simplificado, é este:

```ts
const harness = await Harness.open(await openNodeSqliteStorage("/state/session.sqlite"), { models, registry, env: () => env }, context);
const root = await harness.root(context, { agent: { model, thinkingLevel: "max", cwd } });
harness.resume(); // retoma o que o processo anterior deixou pela metade

while (!closing) {
  const pending = progress.submissionId === undefined
    ? undefined
    : await harness.submission(progress.submissionId, context); // a sessão que estava rodando
  const submission = pending ?? await root.submit(
    { type: "input", content: nudge(progress.session), requestId: `session-${progress.session}` },
    context,
  );
  await saveProgress({ session: progress.session, submissionId: submission.id });
  const result = await submission.wait(context);
  progress = { session: progress.session + 1 };
  await saveProgress(progress);
  if (result.status !== "done") await sleep(backoff()); // só espera depois de falha
}
```

Cada sessão de trabalho é uma submissão para a mesma conversa raiz. Um `requestId` repetido devolve a submissão original em vez de criar outra, e o ID salvo em arquivo deixa um processo novo reencontrar a sessão em andamento.

## Primeiro eu cerquei os agentes, depois tirei as cercas

A primeira versão desses mantenedores tinha portões por todo lado. Os testes rodavam em jobs isolados, sem rede e sem credencial, liberados por um executor à parte. Antes de mexer em código, o agente precisava abrir uma issue. Depois vinha um PR com CI verde e um review separado, só de leitura, antes do merge. Um dos agentes ficou cerca de 14 horas parado num bug que as próprias regras não deixavam corrigir, e cada mudança de regra me custava horas de revisão.

Na sexta, troquei tudo por um desenho simples. Cada repositório ganhou um agente num container próprio, com uma única conversa do Pi Durable gravada em SQLite. Cada agente tinha as quatro ferramentas do Pi, root no container, internet, um diretório persistente e o meu login do GitHub. Ambos rodavam o GPT-6 Luna com thinking no máximo.

A única regra dura do prompt era não publicar segredo nem dado sensível. Um scanner checava o que saía pelos caminhos configurados: um wrapper do `gh` e hooks do git para commit e push. O push protection do GitHub ficava como reserva.

O prompt de sexta pedia o trabalho de um mantenedor sênior: corrigir bugs, melhorar confiabilidade, testes, documentação, experiência de desenvolvimento e performance, e adicionar features úteis que coubessem no propósito do projeto. Pedia também para abrir issues para bugs e ideias de melhoria, mergear o próprio PR com CI verde e nunca esperar por um humano. Cada sessão começava com o mesmo lembrete para conferir o estado atual e continuar melhorando o repositório. A seguinte começava assim que a anterior terminava.

Na sexta, perto do meio-dia, atualizei os pacotes do Pi de 1.0.4 para 1.1.0 com os dois agentes trabalhando. Os dois retomaram a sessão em andamento, e um deles mergeou um PR cerca de um minuto depois. Até terça, o mantenedor do pi-subagents fechou 740 sessões, e o do pi-tmux, 592, cada um sempre na mesma conversa. Quando duas sessões terminaram sem resposta, no domingo, o loop esperou e seguiu.

Como os agentes usavam o meu login, cada issue e cada PR desses quatro dias aparece com o meu usuário no GitHub.

## O backlog real durou uma hora

Quando os agentes começaram, havia três issues abertas. Duas eram de falhas que eu tinha visto usando o pi-subagents: ele rejeitava os novos tipos de mensagem do Pi 1.1.0 e escondia a saída de jobs que falhavam. A terceira pedia checagem de tipos na suíte de testes do pi-tmux. Antes do meio-dia de sexta, as três estavam fechadas.

Daí em diante, a fila era o que os agentes escrevessem. O prompt pedia para continuar melhorando e para abrir issue para cada ideia de melhoria. Eles fizeram exatamente isso.

| | pi-subagents | pi-tmux |
| --- | --- | --- |
| Sessões de trabalho | 740 | 592 |
| Issues abertas no período | 181 | 483 |
| PRs mergeados | 200 | 493 |
| Mediana entre abrir e mergear o PR | 6 min | 2 min |
| Linhas de código fora dos testes, de sexta a terça | 2.890 → 10.706 | 738 → 5.659 |
| Linhas de teste, de sexta a terça | 2.598 → 8.083 | 3.307 → 22.584 |

As sessões do Pi que eu uso no dia a dia têm instrução para abrir uma issue quando uma das extensões falha. Procurei nas 664 issues as que tinham o formato desses relatos, com versão do Pi, ambiente e passos para reproduzir. Achei nove. As outras, os próprios mantenedores escreveram, quase sempre minutos antes do PR que as fechava.

## Sem demanda, o agente escolhe o trabalho mais fácil de provar

O pi-tmux manda trechos da conversa para um modelo escolher o nome da janela. Na sexta de manhã, a proteção contra vazamento era uma frase no prompt desse modelo: nada de segredos, tokens ou informação pessoal. A preocupação tinha fundamento, e o mantenedor começou rejeitando endereços de e-mail no título.

Depois vieram tokens e chaves de Mailgun, Artifactory, Fly.io, Dynatrace, 1Password, Databricks e Linear. Também apareceram números de documento: SSN americano, TFN australiano, My Number japonês, NHS britânico e até o NIR francês de quem nasceu na Córsega. Cada formato virava uma issue, um teste, um PR e um merge com CI verde. Pelos títulos, contei 297 dos 493 PRs do pi-tmux voltados a filtrar credenciais e dados pessoais.

Cada PR, isolado, é defensável. Juntos, os 493 levaram o código do pi-tmux de 738 para 5.659 linhas, e os testes, de 3.307 para 22.584. A função da extensão continua a mesma: dar nome a uma janela.

No pi-subagents, o mesmo padrão apareceu em features. O agente mergeou 23 PRs de feature sem pedido de usuário, 12 deles para encontrar e filtrar definições de agente: por nome, descrição, ferramentas permitidas, modelo, variáveis de ambiente e tags. A descrição da ferramenta que lista agentes, enviada ao modelo em toda sessão com a extensão carregada, agora explica dobra de maiúsculas do Unicode 17.0, com sigma grego e ß alemão.

Enquanto isso, um bug de verdade esperou. No sábado, uma sessão minha abriu uma issue no pi-tmux: quando o modelo de nomes respondia com mais de uma linha, o título da janela não mudava. O mantenedor fechou a issue cinco minutos depois, com uma mensagem de aviso melhor, e o título continuou sem mudar. No domingo, outra sessão minha abriu a mesma reclamação. Só então veio um retry.

Nenhum dos 693 PRs teve review humano, e ninguém daria conta de mais de 170 por dia, a média desses quatro dias. Em [Quando commits escalam mais rápido que reviews](/quando-commits-escalam-mais-rapido-que-reviews/), tratei o CI como porteiro. Aqui, o porteiro conferia testes que o próprio agente tinha acabado de escrever.

## Proibir o trabalho inventado no prompt resolveu metade

Na segunda à noite, reescrevi o prompt. O agente só podia adicionar feature a pedido de um usuário e só podia abrir issue para bug reproduzido ou pedido de usuário. Também não podia criar, por conta própria, regras de detecção, formatos de identificador, validadores ou categorias. Antes de abrir issue ou PR, precisava reproduzir o problema e citar o arquivo, a linha ou a saída.

O pi-tmux parou de adicionar formatos e passou a corrigir o que tinha construído. Entre 3h e 12h22 de terça, ele abriu 24 PRs, e 17 ajustavam casos de borda e falsos positivos do filtro: token cortado no limite do texto enviado ao modelo, prosa grudada num token, espaço em branco na borda. O código de sábado virou o backlog de terça, o mesmo resíduo que descrevi em [O benchmark reinicia o repositório. Seu time não](/o-benchmark-reinicia-o-repositorio-seu-time-nao/).

O pi-subagents ficou sem trabalho. Entre 0h52 e 4h14 de terça, o mantenedor rodou 509 sessões, uma a cada 17 segundos na mediana. Quase todas terminaram com o mesmo resumo: main limpa, nenhum PR aberto, a única issue aberta esperando uma migração de runners do GitHub, nada novo dentro do escopo. Cada uma passava pelo modelo com thinking no máximo.

O loop só espera depois de uma falha. Quando uma sessão conclui que não há nada a fazer, ela termina com sucesso, e a próxima começa na hora.

Em julho, escrevi que [as fronteiras importantes precisam viver fora do prompt](/excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/). Na segunda, coloquei a regra de escopo no prompt, e ela se comportou como prompt. Mudou o que o modelo escolhia, e o loop continuou igual.

## A única fronteira dependia de uma lista

No sábado, às 12h20, o mantenedor do pi-tmux abriu uma issue pedindo para filtrar chaves de API da Resend. O corpo trazia um valor com formato de chave da Resend.

O scanner que vigiava as publicações do agente conhecia sete formatos, mais os valores exatos das credenciais que o agente usava. A Resend não estava entre eles, e a issue foi publicada. Dois segundos depois, o secret scanning do GitHub, que também lê corpo e comentários de issue, abriu um alerta, com validade desconhecida.

O mantenedor só encontrou o alerta na madrugada de terça. Tirou o valor do corpo visível, reabriu a issue e recomendou revogar a chave, se ela fosse real. Pela avaliação dele, o valor não parecia fixture de teste nem placeholder óbvio. Na terça à tarde, confirmei que o valor era só um exemplo e fechei o alerta como falso positivo. Uma chave real teria saído pelo mesmo caminho e ficaria no histórico de edições da issue, como o exemplo ficou.

Em quatro dias, o mantenedor abriu quase 300 PRs para ensinar o pi-tmux a reconhecer credenciais e dados pessoais, enquanto o scanner dele continuava com sete formatos. Na terça, desliguei os dois agentes, e o scanner ganhou um oitavo formato, a mesma correção que o mantenedor do pi-tmux passou o fim de semana fazendo.

## O que a durabilidade não decide

O Pi Durable fez a parte dele. Nesses quatro dias, nenhum restart ou atualização fez um agente perder a sessão em andamento. As três falhas apareceram no código que eu escrevi em volta da biblioteca, e mais durabilidade não resolveria nenhuma delas.

A fonte de trabalho precisa vir de fora do agente: issue de usuário, CI vermelho, release nova do Pi, alerta de dependência. Quando essa fila está vazia, "nada a fazer" é um resultado válido.

O loop precisa de um estado ocioso. Em vez de iniciar uma sessão nova a cada 17 segundos, ele pode dormir até chegar um evento, como uma issue nova, um comentário ou um CI que falhou. Quando o evento chega, o agente continua livre para decidir o que fazer.

A fronteira de publicação não pode depender só dos formatos que alguém lembrou de listar. Corpo de issue é publicação, como um push. Um valor com cara de segredo, de formato conhecido ou não, não deveria sair, nem como exemplo.

Não compro contagem de PR mergeado como medida de mantenedor autônomo. Das 664 issues, as nove que vieram de uso real eram as únicas com alguém esperando do outro lado, e o mantenedor fechou cada uma em menos de 40 minutos. É esse trabalho que eu quero medir.

> Se o seu agente acordar amanhã sem nenhuma issue aberta, o que o loop manda ele fazer?

## Fontes

- [Mario Zechner: What I learned building an opinionated and minimal coding agent](https://mariozechner.at/posts/2025-11-30-pi-coding-agent/)
- [Pi: README](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/README.md)
- [Pi: How Pi Works](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/how-pi-works.md)
- [Pi: CLI e ferramentas padrão](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/cli.md)
- [Pi: Run Pi safely](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/security.md)
- [Earendil: Pi Durable](https://earendil.com/posts/pi-durable/)
- [Pi Durable: README](https://github.com/earendil-works/pi/blob/main/packages/durable/README.md)
- [leocavalcante/pi-subagents](https://github.com/leocavalcante/pi-subagents)
- [leocavalcante/pi-tmux](https://github.com/leocavalcante/pi-tmux)
- [GitHub Docs: About secret scanning](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning)
- [Quando commits escalam mais rápido que reviews](/quando-commits-escalam-mais-rapido-que-reviews/)
- [Excesso de agência é bug de confiabilidade, não só risco de segurança](/excesso-de-agencia-e-bug-de-confiabilidade-nao-so-risco-de-seguranca/)
- [O benchmark reinicia o repositório. Seu time não](/o-benchmark-reinicia-o-repositorio-seu-time-nao/)
