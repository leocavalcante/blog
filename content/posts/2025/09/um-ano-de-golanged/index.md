---
title: Um Ano de "Golanged"
description: Há exatamente um ano, um commit com a mensagem "Golanged" marcava o início de uma nova fase na minha carreira como desenvolvedor. Era meu primeiro passo com a linguagem Go em um...
date: "2025-09-24T09:53:02-03:00"
updated: ""
draft: false
tags:
    - go
    - developer-experience
    - monorepo
    - career
    - pragmatism
url: /um-ano-de-golanged/
cover: cover.png
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Há exatamente um ano, um commit com a mensagem "Golanged" marcava o início de uma nova fase na minha carreira como desenvolvedor. Era meu primeiro passo com a linguagem Go em um projeto profissional, dentro de um monorepo que mantenho até hoje. Mal sabia eu que aquela palavra, quase uma brincadeira, representaria a descoberta de um universo de possibilidades. Hoje, celebro não só a data, mas a decisão de embarcar nessa jornada.

Go, ou Golang, é uma linguagem que me conquistou por sua **simplicidade**, no sentido mais poderoso da palavra. Em um mundo de frameworks complexos e múltiplas formas de se chegar ao mesmo resultado, Go oferece um caminho mais direto, quase uma filosofia de "o jeito certo de fazer". E o mais incrível é como a comunidade de desenvolvedores abraça essa ideia, criando um ecossistema de engenheiros pragmáticos focados em construir soluções eficientes e legíveis.

---

### Os Pilares do Go: Por que a linguagem brilha?

Minha experiência ao longo deste ano me permitiu vivenciar na prática os benefícios que tanto lia a respeito. Se eu pudesse resumir os pontos altos de usar Go, destacaria:

* **Simplicidade e Legibilidade:** A sintaxe do Go é enxuta e clara. Com poucas palavras-chave e uma formatação padrão (graças ao `gofmt`), o código se torna incrivelmente fácil de ler e manter. Isso acelera o onboarding de novos desenvolvedores e facilita a colaboração, pois o estilo do código é consistente em toda a base.

* **Performance Excepcional:** Go é uma linguagem compilada que gera binários nativos e otimizados. O tempo de compilação é surpreendentemente rápido, e o desempenho em tempo de execução é fantástico, aproximando-se de linguagens como C++, mas com uma complexidade muito menor.

* **Concorrência Nativa:** Este é, talvez, o superpoder do Go. Com **Goroutines** e **Channels**, escrever código concorrente (que executa várias tarefas "ao mesmo tempo") é trivial e seguro. Em vez de lidar com a complexidade de threads e locks, Go oferece um modelo elegante que simplifica o desenvolvimento de sistemas de alta performance e que fazem uso máximo dos processadores modernos.

* **Biblioteca Padrão Robusta:** Go vem com uma "bateria inclusa". Sua biblioteca padrão é vasta e cobre desde a criação de servidores web (`net/http`) até tarefas de criptografia e manipulação de dados, reduzindo a necessidade de dependências externas para funcionalidades essenciais.


---

### Bônus: A Magia do Monorepo (e não, não é um Monolito!)

Minha jornada com Go aconteceu dentro de um **monorepo**, e essa combinação se provou extremamente poderosa. É crucial desfazer uma confusão comum: **monorepo não é sinônimo de monolito**.

* Um **monolito** é uma *arquitetura de software* onde toda a aplicação é uma única e grande unidade de código, fortemente acoplada.

* Um **monorepo** é uma *estratégia de versionamento de código* onde múltiplos projetos, bibliotecas e serviços (que podem ser microsserviços, por exemplo) coexistem no mesmo repositório Git.


As vantagens de trabalhar com um monorepo foram claras desde o início:

* **Compartilhamento de Código Simplificado:** Reutilizar código entre diferentes serviços é tão simples quanto importar um pacote local. Não há necessidade de publicar versões em um registro de pacotes e gerenciar dependências externas.

* **Refatoração Atômica:** Precisa mudar uma API que é consumida por vários serviços? Em um monorepo, você pode atualizar a API e todos os seus consumidores em um único commit, garantindo que tudo continue funcionando junto.

* **Gerenciamento Único de Dependências:** Todos os projetos compartilham a mesma versão das dependências, evitando o "inferno das dependências" e garantindo consistência em todo o ecossistema.

* **Colaboração Facilitada:** Equipes diferentes têm visibilidade do código umas das outras, o que incentiva a colaboração e a padronização de boas práticas.


### Pra finalizar

Olhando para trás, aquele commit "Golanged" foi mais do que apenas o início de um projeto. Foi o começo de uma nova forma de pensar sobre software: mais simples, mais direta e mais pragmática. A combinação da elegância do Go com a eficiência organizacional de um monorepo criou um ambiente de desenvolvimento produtivo e agradável.

Se você busca uma linguagem que valoriza a clareza, a performance e a produtividade do desenvolvedor, minha experiência de um ano grita: dê uma chance ao Go. Você pode acabar se surpreendendo.
