---
title: Crie uma API GraphQL sobre o Swoole
description: Estou assumindo que você já sabe o que são GraphQL e Swoole, então que tal irmos direto para o código?
date: "2019-08-10T16:24:14-03:00"
updated: "2019-08-10T16:53:06-03:00"
draft: false
tags:
    - api
    - php
    - swoole
    - async
    - architecture
url: /archive/medium/build-a-graphql-api-on-top-of-swoole-5de5d71b6e12/
cover: ""
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Estou assumindo que você já sabe o que são [GraphQL](https://graphql.org/) e [Swoole](https://www.swoole.co.uk), então que tal irmos direto para o código?

O que talvez você ainda não conheça é o [Siler](https://github.com/leocavalcante/siler)! Ele é um conjunto de abstrações de alto nível e propósito geral que busca oferecer uma API para programação declarativa em PHP.

Com o [Siler](https://github.com/leocavalcante/siler), podemos abstrair as partes mais “difíceis” de ferramentas populares como GraphQL e, mais recentemente, Swoole. E sim, eu sou o autor, então fique à vontade para abrir issues ou fazer perguntas sobre ele.

**“Falar é fácil, mostre-me o código”. Vamos lá!**

Quero deixar isto o mais simples possível para podermos focar em usar GraphQL e Swoole através do Siler, em vez de resolver problemas difíceis de domínio e regra de negócio. Por isso, vamos implementar uma boa e velha lista de tarefas.

```
$ mkdir todos
$ cd todos/
```

Não sei você, mas eu gosto muito de começar um projeto do zero, em um terreno limpo, em vez de usar boilerplate ou código de esqueleto.

```
$ composer require leocavalcante/siler
$ composer require webonyx/graphql-php
$ composer require --dev swoole/ide-helper
```

Essas são nossas dependências. O Siler em si não reimplementa um parser/executor GraphQL; ele constrói sobre o trabalho atual da Webonyx. O mesmo vale para o Swoole, claro, então garanta que a extensão Swoole esteja instalada e funcionando no seu ambiente PHP.

### O schema

Um Todo é simples: precisamos de um ID para identificá-lo de forma única, um título para funcionar como uma descrição curta, um corpo para funcionar como uma descrição completa e uma flag para indicar se ele já foi concluído.

<a href="https://medium.com/media/2e88bfd9a29510097ef679b0a71f49ba/href">https://medium.com/media/2e88bfd9a29510097ef679b0a71f49ba/href</a>

Também precisamos de um tipo para funcionar como Input e, claro, se você conhece GraphQL, de um tipo Query para consultar Todos e de um tipo Mutation para criá-los, alterá-los e removê-los. Aqui está nosso schema completo:

<a href="https://medium.com/media/26b96d722cec48bc9aa61fd9ae544465/href">https://medium.com/media/26b96d722cec48bc9aa61fd9ae544465/href</a>

É isso! Vamos então para o PHP.

### O servidor

Mais uma vez, assumindo que você já sabe, mas... usando Swoole, construímos nosso próprio servidor HTTP, assim como no Node.js. É uma boa, não é?

<a href="https://medium.com/media/be55c26f415cf5ff2ca4f00d8886d0cc/href">https://medium.com/media/be55c26f415cf5ff2ca4f00d8886d0cc/href</a>

Você provavelmente viu algo diferente na documentação do Swoole. **Isso é o Siler trabalhando!** Deixando tudo ainda mais simples e agradável. Como funções PHP comuns, mas pegando emprestado o máximo possível de pureza, imutabilidade e funções de alta ordem do paradigma de Programação Funcional.

Inicie o servidor usando php index.php, acesse [http://localhost:8000](http://localhost:8000) (ou qualquer porta que você sobrescrever usando a variável de ambiente PORT) e confira se está funcionando.

### O domínio

Agora é hora de trabalhar no nosso domínio.

Primeiro definimos nosso módulo Todos. É o módulo que vai conter as funções que trabalham em um Todo. Eu sei, isso não é muito orientado a objetos, mas eu realmente não me importo, não quero seguir por esse caminho. Podemos trabalhar nisso usando qualquer paradigma que você preferir; você verá que ele não está acoplado ao restante do código.

<a href="https://medium.com/media/4a6af67ad9bf9c50759a627b45ad2a4d/href">https://medium.com/media/4a6af67ad9bf9c50759a627b45ad2a4d/href</a>

Por enquanto, é isso que vamos fazer: find e save. find pode receber um Criteria; é assim que você pode construir várias formas diferentes de consultar um Todo. Eles são simples:

<a href="https://medium.com/media/e45cbd933bfe6d0c646809484bde3d68/href">https://medium.com/media/e45cbd933bfe6d0c646809484bde3d68/href</a>

A aplicação

Não estou tentando fazer DDD aqui, mas é um conceito legal, certo? Depois de definir nosso domínio, estamos prontos para passar para a próxima camada e começar a construir a camada de aplicação. Nada mais limpo e útil para testes do que uma implementação em memória de algum I/O.

<a href="https://medium.com/media/c499d0f0fe5e22551e7060775818b13b/href">https://medium.com/media/c499d0f0fe5e22551e7060775818b13b/href</a>

Fica bem claro o que está acontecendo aqui, certo? Estamos buscando e salvando em um array em memória.

Ter a interface Todos e trabalhar em suas implementações abre uma grande variedade de possibilidades, desde testes usando implementações em memória até trabalho real com implementações em PDO ou NoSQL. Isso vai ficar mais claro agora quando você vir como os Resolvers são construídos:

### Os resolvers

<a href="https://medium.com/media/09ecbbec0ecb5186e18c4ca76a7282a8/href">https://medium.com/media/09ecbbec0ecb5186e18c4ca76a7282a8/href</a>

O resolver de Query basicamente vincula um Criteria a um módulo Todos. Note que os dois resolvers dependem da abstração de um módulo Todos, não de uma implementação.

O resolver Save mostra um pouco mais de sua funcionalidade; talvez você os associe a um Controller do padrão MVC.

Agora precisamos juntar essas peças de uma forma que depois seja fácil dizer ao construtor do Schema qual resolver ele deve usar. Bem, que tal uma factory?

<a href="https://medium.com/media/3b939a3f82e95f81564e4f2635a22ac3/href">https://medium.com/media/3b939a3f82e95f81564e4f2635a22ac3/href</a>

### O servidor (atualização)

Nosso código-fonte está todo lá: nosso domínio, suas implementações e os resolvers funcionando como a aplicação. Agora é hora de conectar tudo isso ao servidor:

<a href="https://medium.com/media/0f0f3bffa0c35181542fd0447f647c86/href">https://medium.com/media/0f0f3bffa0c35181542fd0447f647c86/href</a>

E aí está nossa API **GraphQL** rodando sobre o **Swoole** com a ajuda do **Siler**!

Espero que você tenha gostado. Fique à vontade para fazer perguntas.

[O código-fonte completo está disponível aqui.](https://github.com/leocavalcante/swoole-graphql-api)

Obrigado!
