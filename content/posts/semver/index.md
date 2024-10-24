---
title: O que é versionamento semântico?
description: O versionamento semântico, também chamado de **SemVer**, é um padrão usado por desenvolvedores para numerar versões de softwares de maneira clara e previsível. Ele facilita o en...
date: "2024-10-24T10:01:27-03:00"
updated: ""
draft: false
tags:
    - git
    - semantic-versioning
    - version-control
url: /semver/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

O versionamento semântico, também chamado de **SemVer**, é um padrão usado por desenvolvedores para numerar versões de softwares de maneira clara e previsível. Ele facilita o entendimento de quais mudanças ocorreram no software e qual o impacto dessas alterações. Basicamente, o SemVer usa uma notação de três números no formato **X.Y.Z**, onde cada número tem um significado específico.

## Estrutura do SemVer

A estrutura do versionamento semântico é composta por três partes:

1. **X (Major)**: Versão maior. Esse número muda quando há alterações que quebram a compatibilidade com versões anteriores (ou seja, mudanças que afetam o comportamento esperado). Exemplos disso são mudanças de API que podem exigir que outros desenvolvedores modifiquem seus códigos.

2. **Y (Minor)**: Versão menor. Esse número é incrementado quando são adicionadas funcionalidades novas, mas que são compatíveis com as versões anteriores. Por exemplo, novas funcionalidades ou melhorias que não afetam o funcionamento existente.

3. **Z (Patch)**: Correção de bugs. Esse número é usado para atualizações que consertam problemas ou erros, sem adicionar novas funcionalidades ou quebrar a compatibilidade com as versões anteriores.


Por exemplo, se você tem a versão **1.4.2**:

* **1** indica uma versão maior (major),

* **4** indica que quatro conjuntos de novas funcionalidades foram adicionadas,

* **2** indica que houve duas correções de bugs desde a última mudança.


## Por que usar o versionamento semântico?

O SemVer facilita muito o gerenciamento de versões de software, especialmente quando o código é usado por outras pessoas (como bibliotecas ou APIs). Ele deixa claro quando uma atualização vai exigir mudanças no código de quem está usando o software, ou quando é seguro fazer uma atualização sem preocupações. Veja alguns benefícios:

* **Transparência**: Saber o tipo de mudança (bug fix, funcionalidade ou quebra de compatibilidade) de forma clara.

* **Facilidade de atualização**: Quem utiliza o software sabe se a atualização vai exigir mudanças no próprio código.

* **Colaboração**: Quando várias pessoas trabalham no mesmo projeto, o versionamento facilita a organização das contribuições.


## Como aplicar o versionamento semântico?

Para usar o SemVer corretamente, siga essas diretrizes:

1. **Comece com a versão 1.0.0** quando o software for lançado publicamente. Versões abaixo disso, como 0.x.x, são para fases experimentais ou de testes, onde não há garantias de estabilidade.

2. **Altere o número Major** (X) se as mudanças não forem compatíveis com versões anteriores.

3. **Altere o número Minor** (Y) se você adicionar novas funcionalidades, mas mantendo a compatibilidade.

4. **Altere o número Patch** (Z) quando corrigir bugs ou problemas menores.


## Exemplo prático

Vamos dizer que você lançou uma API na versão **2.3.1**. Se você corrigir um pequeno bug, a nova versão será **2.3.2**. Agora, se você adicionar uma nova funcionalidade sem quebrar a compatibilidade, seria **2.4.0**. No caso de uma alteração grande que muda o funcionamento da API, como remover ou alterar endpoints, você teria **3.0.0**.

## Conclusão

O versionamento semântico é essencial para manter a organização de projetos e facilitar a vida tanto dos desenvolvedores que mantêm o software quanto de quem utiliza. Ele cria uma linguagem comum para que todos entendam rapidamente o impacto de uma atualização e ajudem a evitar surpresas indesejadas.

Se quiser saber mais detalhes, confira o [site oficial do SemVer](https://semver.org/).
