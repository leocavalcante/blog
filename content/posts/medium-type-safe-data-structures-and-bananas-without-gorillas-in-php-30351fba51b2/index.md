---
title: Estruturas de dados type-safe e bananas sem gorilas em PHP
description: Eu costumava amar tudo sobre programação orientada a objetos, ignorando todo o resto. Quando finalmente entendi, achei que todo software deveria ser desenvolvido usando OO...
date: "2017-04-30T17:23:50-03:00"
updated: "2017-04-30T17:23:50-03:00"
draft: false
tags:
    - functional-programming
    - object-oriented
    - php
    - programming
url: /archive/medium/type-safe-data-structures-and-bananas-without-gorillas-in-php-30351fba51b2/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Eu costumava amar tudo sobre programação orientada a objetos, ignorando todo o resto. Quando finalmente entendi, achei que todo software deveria ser desenvolvido usando OO e, se não fosse, estaria errado.

Enquanto isso, eu estava muito feliz estudando JavaScript, até que fui atingido por essa coisa de **Programação Funcional**. O primeiro pensamento comum foi: _é programação com funções?_ Sim e **não**. Descobri que é sobre funções, mas não deveria ser código imperativo dentro de funções; vai muito além. Enfim, este texto não é sobre isso, mas estudando FP e linguagens funcionais descobri que **OO não é um conceito à prova de balas; ele tem algumas falhas**.

_Design patterns, SOLID, GRASP etc. são princípios em OO para resolver problemas que a própria OO causa, não para essencialmente torná-la melhor._

Juntando essas ideias de Programação Funcional com algumas coisas que aprendi com a comunidade JavaScript, passou pela minha cabeça um pouco de código para mostrar.

Mas primeiro, um problema do PHP. Faltam estruturas de dados type-safe. Você não consegue definir tipos estritamente para propriedades; uma maneira de resolver isso é definir getters e setters. Vou usar uma versão reduzida de getter/setter nos exemplos para garantir type safety.

Vamos imaginar que temos um Swimmer com name e wetsuit:

<a href="https://medium.com/media/c041644022078c8ba3e8a64e08313245/href">https://medium.com/media/c041644022078c8ba3e8a64e08313245/href</a>

Legal! name e wetsuit são estritamente Strings. Não podem ser outra coisa. Se fossem propriedades públicas, poderíamos atribuir Integers a elas. E nosso $swimmer pode swim().

<a href="https://medium.com/media/603a7f9fca1d6a620a51abe3947b5db1/href">https://medium.com/media/603a7f9fca1d6a620a51abe3947b5db1/href</a>

Ok, vamos mergulhar em um problema de OO. Imagine que agora temos um Cyclist, mas que também pode swim(), como vemos em competições de triatlo.

![](cover.jpg)

Adoro memes antigos<a href="https://medium.com/media/f2cd9cabae1bf0e710b737f674957225/href">https://medium.com/media/f2cd9cabae1bf0e710b737f674957225/href</a>

Fácil!

<a href="https://medium.com/media/1d31cc7a64edbe9cb25391d9089cb9a3/href">https://medium.com/media/1d31cc7a64edbe9cb25391d9089cb9a3/href</a>

#### E agora?

Bem, imagine que agora queremos um Cyclist simples, que não faz swim(). Como fazer isso? Extrair swim() para um Trait? SwimmerInterface? Cyclist e SwimmerCyclist? E se precisarmos de um Runner para um Triathlete completo? SwimmerCyclistRunner? Um Triathlete que implementa Interfaces e usa Traits? Então as classes serão apenas declarações de tipo e as implementações ficarão divididas em Traits? Como testar tudo isso? **MEU DEUS!**

> O problema com as linguagens orientadas a objetos é que elas carregam todo esse ambiente implícito junto. Você queria uma banana, mas o que recebeu foi um gorila segurando a banana e a selva inteira. — Joe Armstrong

> Se você tem código referencialmente transparente, se tem funções puras, todos os dados entram pelos argumentos de entrada e tudo sai, sem deixar estado para trás; isso é incrivelmente reutilizável. — Joe Armstrong

### Funções puras

E se separarmos comportamento de dados em funções puras? swim(), ride() e run() como funções puras esperando exatamente o que precisam para serem chamadas com sucesso?

Primeiro, vamos definir nossas estruturas de dados type-safe usando interfaces:

<a href="https://medium.com/media/661745b3c769099257804b8c1d4cbc05/href">https://medium.com/media/661745b3c769099257804b8c1d4cbc05/href</a>

E as implementações que vamos sufixar com Type:

<a href="https://medium.com/media/e7a14e1c180ad00db0cf6ab65303f63f/href">https://medium.com/media/e7a14e1c180ad00db0cf6ab65303f63f/href</a>

Note que isso é apenas para conseguir estruturas de dados type-safe. Todo esse boilerplate poderia ser evitado por RFCs como [Typed Properties](https://wiki.php.net/rfc/typed-properties) e [Property Type Hint](https://wiki.php.net/rfc/property_type_hints).

Mas vamos seguir e adicionar nossas **funções puras** para cada comportamento:

<a href="https://medium.com/media/d00035d3ad8f5bd2d078303c2e132342/href">https://medium.com/media/d00035d3ad8f5bd2d078303c2e132342/href</a>

E por fim, a prova de conceito, o Triathlete:

<a href="https://medium.com/media/3f5e0bf761da03b2e6e82914bb60ff2a/href">https://medium.com/media/3f5e0bf761da03b2e6e82914bb60ff2a/href</a>

Agora podemos ter todo tipo de reutilização de comportamento: todo mundo pode swim() se for um Swimmer, todo mundo pode ride() se for um Cyclist e todo mundo pode run() se for um Runner. E Triathlete é os três e pode usar exatamente o mesmo comportamento deles.

<a href="https://medium.com/media/28bf7cd80699c6aeace7c74a209cca91/href">https://medium.com/media/28bf7cd80699c6aeace7c74a209cca91/href</a>

O que você acha? Já teve alguma ideia sobre essa abordagem? Existem desvantagens em separar dados e comportamento? **Deixe alguns comentários abaixo.**

_P.S.: Eu sei, é muito boilerplate para garantir type safety._
