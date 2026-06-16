---
title: Why Go Should Sometimes Be a No-Go?
description: A linguagem Go foi alvo de críticas por sua simplicidade e filosofia de design, em um artigo recente chamado *"Why Go Should Sometimes Be a No-Go"*, onde o autor levanta alguns ...
date: "2025-02-03T09:00:09-03:00"
updated: ""
draft: false
tags:
    - go
    - language-design
    - pragmatism
    - developer-experience
    - philosophy
url: /why-go-should-sometimes-be-a-no-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

A linguagem Go foi alvo de críticas por sua simplicidade e filosofia de design, em um artigo recente chamado *"Why Go Should Sometimes Be a No-Go"*, onde o autor levanta alguns pontos negativos sobre a linguagem, argumentando que sua abordagem minimalista pode ser uma limitação em certos contextos. No entanto, esses argumentos podem ser contrapostos com uma visão mais ampla sobre os benefícios e propósitos do Go.

## 1. Go é entediante? Eficiência acima de tudo

O artigo argumenta que Go é "entediante" por não oferecer construções como `map`, `filter` e `reduce`, exigindo que os desenvolvedores implementem essas operações manualmente com loops. No entanto, essa escolha de design não é uma falha, mas sim uma decisão consciente para manter a legibilidade e previsibilidade do código.

Ao evitar abstrações excessivas, Go facilita a manutenção e a depuração de código. Em muitas linguagens, o uso intensivo de construções funcionais pode gerar dificuldades para novos desenvolvedores compreenderem rapidamente um código legado. Além disso, ao forçar uma abordagem mais explícita, Go reduz a complexidade cognitiva e minimiza erros inesperados causados por comportamentos implícitos em funções complexas.

Outro ponto relevante é que, em sistemas de alto desempenho e aplicações distribuídas, loops explícitos frequentemente superam abordagens baseadas em funções de ordem superior em termos de eficiência, uma vez que evitam a alocação desnecessária de memória e overheads relacionados à abstração excessiva.

## 2. Go desencoraja princípios de Clean Code? Na verdade, ele os reforça

A simplicidade do Go incentiva o uso de práticas claras e diretas de desenvolvimento. Em vez de permitir múltiplas formas de resolver o mesmo problema, Go impõe uma padronização que reduz complexidade e facilita a colaboração em equipe. O foco no código explícito evita o uso excessivo de abstrações desnecessárias, tornando o código mais compreensível para todos os membros de um time.

Ao adotar convenções rígidas, como a formatação automática pelo `gofmt`, Go remove discussões sobre estilo e formatação, permitindo que os desenvolvedores foquem no que realmente importa: a lógica do programa. Além disso, a ausência de exceções (substituídas pelo tratamento explícito de erros) obriga os desenvolvedores a lidar de forma estruturada com falhas, tornando os sistemas mais robustos e previsíveis.

## 3. Go é pequeno e força a filosofia Do It Yourself? Modularidade é um benefício

O artigo menciona que bibliotecas externas são amplamente utilizadas para suprir funcionalidades que a linguagem não oferece nativamente. Esse argumento sugere que Go é "incompleto", mas a realidade é que essa modularidade é uma vantagem.

A filosofia do Go segue o princípio UNIX: "faça uma coisa e faça bem feito". Em vez de inflar a linguagem com funcionalidades que nem todos os projetos precisam, Go permite que desenvolvedores escolham ferramentas externas conforme a necessidade. Isso dá liberdade para adaptar a linguagem a diferentes contextos sem sobrecarregar seu núcleo.

Ao invés de obrigar todos os desenvolvedores a carregar uma grande quantidade de recursos embutidos na linguagem, Go permite um ecossistema enxuto e eficiente, onde pacotes externos podem ser usados conforme a necessidade específica do projeto. Esse modelo mantém a base da linguagem leve e otimizada, permitindo um melhor desempenho e menor tempo de compilação.

## 4. Em Go, há apenas uma forma de fazer as coisas? E isso é ruim?

A existência de um único modo de resolver problemas comuns evita debates desnecessários e simplifica a leitura e manutenção do código. Isso não significa falta de flexibilidade, mas sim um design pragmático que prioriza eficiência. Muitas linguagens que oferecem múltiplas formas de realizar uma mesma tarefa acabam gerando código inconsistente e difícil de padronizar dentro de uma equipe.

Além disso, a previsibilidade do código em Go reduz a curva de aprendizado para novos desenvolvedores, permitindo que equipes ampliem sua força de trabalho de forma mais eficiente. O código escrito por um engenheiro pode ser rapidamente compreendido e mantido por outro, sem a necessidade de navegar por múltiplas abordagens de implementação.

Outro benefício é que, ao restringir a linguagem a um conjunto essencial de construções, Go facilita a otimização e análise estática do código, permitindo melhores práticas de engenharia de software e maior controle sobre o desempenho da aplicação.

## 5. Debugging no Go não é divertido? Ferramentas modernas ajudam

Embora o depurador nativo do Go tenha sido básico no passado, hoje há ferramentas avançadas como Delve, que oferecem um ambiente poderoso para debugging. Além disso, a própria simplicidade da linguagem reduz a necessidade de depuração intensiva, pois erros tendem a ser mais óbvios e fáceis de rastrear.

O modelo explícito de tratamento de erros do Go também ajuda a evitar problemas silenciosos. Como os desenvolvedores precisam lidar diretamente com os erros, é menos provável que falhas passem despercebidas, reduzindo a necessidade de um debugging aprofundado. Além disso, a combinação de `panic/recover` e profiling embutido na linguagem oferece mecanismos eficazes para análise de falhas e otimização de desempenho.

Outro ponto importante é que a compilação rápida e a tipagem estática do Go ajudam a identificar erros antes mesmo da execução, minimizando a incidência de falhas em tempo de execução e reduzindo a necessidade de debugging extensivo.

---

Go não é perfeito para todos os cenários, assim como qualquer linguagem. No entanto, suas características — simplicidade, estabilidade e modularidade — fazem dela uma escolha estratégica para muitos projetos, especialmente aqueles que valorizam desempenho, escalabilidade e facilidade de manutenção. O que pode parecer uma limitação à primeira vista muitas vezes se traduz em benefícios a longo prazo.

A filosofia do Go prioriza eficiência, clareza e previsibilidade, eliminando complexidades desnecessárias e garantindo um ambiente de desenvolvimento produtivo e confiável. Embora algumas decisões da linguagem possam parecer rígidas, elas promovem boas práticas de engenharia de software e resultam em sistemas mais robustos e fáceis de manter.
