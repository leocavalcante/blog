---
title: Nano, o micro-framework pra Swoole que é meu novo xodó
description: Inspirado no artigo sobre Hyperf do grade @Leonardo do Carmo (e também na dica dele sobre a hashnode hehe) resolvi passar por aqui e escrever sobre o  Nano, o micro-framework pr...
date: "2021-07-24T22:17:38-03:00"
updated: ""
draft: false
tags:
    - swoole
    - php
    - architecture
    - async
    - coroutines
url: /nano-o-micro-framework-pra-swoole-que-e-meu-novo-xodo/
cover: ""
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Inspirado no [artigo sobre Hyperf](https://leocarmo.dev/hyperf-php-coroutine-framework-baseado-em-swoole) do grade @[Leonardo do Carmo](@leocarmo) (e também na dica dele sobre a hashnode hehe) resolvi passar por aqui e escrever sobre o  [Nano](https://nano.hyperf.wiki/), o micro-framework pra Swoole da galera do Hyperf.

Pra quem gosta de analogias, assim como temos o Laravel e o Lumen, temos o Hyperf e o Nano. **Ou mais ou menos isso**:

É uma analogia bem simplória, porque na verdade o Nano é como se fosse um Hyperf completo, diferente do que a gente vê entre Laravel-Lumen, a única feature que você fica sem são as Annotations.

**Qual é a vantagem então se ele é um Hyperf sem uma das features?** - Você deve estar se perguntando.

- Zero-configurações
- Sem estruturas pré-definidas
- Uma distribuição mínima do Hyperf
- Um único arquivo PHP e você já está rodando

Pessoalmente sou um fã de carteirinha dessa simplicidade, não a toa fiz a  [Siler](https://github.com/leocavalcante/siler), a Nano consegue trazer toda essa simplicidade  mantendo compatibilidade com todos\* (só não o de Annotations) os pacotes disponíveis pro Hyperf e ter Corrotinas como *first-class citizens*.

*Confesso que se tivesse conhecido a dupla Hyperf-Nano antes, talvez não tivesse criado a Siler* 🤭

Beleza, parece bem legal, mas *talk is shit, show me the code*.

Como dito anteriormente, a Nano não vai te chatear com estruturas de diretórios, então você pode começar literalmente com um diretório vazio:

```shell
mkdir hello-nano
cd hello-nano
```

Agora trazer a Nano é tão simples quanto qualquer outro pacote do PHP. **Se você programa em PHP e ainda não conhece o Composer, volte duas casas.**

```shell
composer require hyperf/nano
```

Agora tudo o que você precisa é de apenas um arquivo PHP, como se fosse um PHP de rua, mas com todo tipo de componente para aplicações de alto-nível disponíveis a um `composer install` e tudo isso rodando nas Corrotinas da Swoole.

```php
<?php
// index.php
use Hyperf\Nano\Factory\AppFactory;

require_once __DIR__ . '/vendor/autoload.php';

$app = AppFactory::create();

$app->get('/', function () {

    $user = $this->request->input('user', 'nano');
    $method = $this->request->getMethod();

    return [
        'message' => "hello {$user}",
        'method' => $method,
    ];

});

$app->run();
```

Pra começar a brincadeira é só rodar:

```shell
php index.php start
```

E **voilà**!

A porta padrão é a `9501`, então é só acessar http://localhost:9501. Pra mudar o host e a porta é no próprio método `AppFactory::create()`:

```php
AppFactory::create('127.0.0.1', 8080);
```

Agora é só deixar a imaginação tomar conta e você ainda vai ter todo o suporte de *containers* de injeção de dependência, *orms* para acessar banco de dados, sistema para disparo de eventos e por aí vai!

Não esquece de acessar o site https://nano.hyperf.wiki/#/en/ e começar a explorar todas as possibilidades.

Grande abraço!
