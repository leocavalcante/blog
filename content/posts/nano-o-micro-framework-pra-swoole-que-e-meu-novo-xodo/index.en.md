---
title: Nano, the Swoole micro-framework that is my new favorite
description: Inspired by the article about Hyperf by the great @Leonardo do Carmo (and also by his tip about Hashnode hehe), I decided to stop by and write about Nano, the S...
date: "2021-07-24T22:17:38-03:00"
updated: ""
draft: false
tags:
    - swoole
    - php
    - architecture
    - async
    - coroutines
url: /en/nano-o-micro-framework-pra-swoole-que-e-meu-novo-xodo/
cover: ""
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Inspired by the [article about Hyperf](https://leocarmo.dev/hyperf-php-coroutine-framework-baseado-em-swoole) by the great @[Leonardo do Carmo](@leocarmo) (and also by his tip about Hashnode hehe), I decided to stop by and write about [Nano](https://nano.hyperf.wiki/), the Swoole micro-framework from the Hyperf folks.

For those who like analogies, just as we have Laravel and Lumen, we have Hyperf and Nano. **Or something like that**:

It is a very simplistic analogy, because Nano is actually like a complete Hyperf, unlike what we see between Laravel and Lumen. The only feature you do not get is Annotations.

**So what is the advantage if it is Hyperf without one of the features?** - You may be asking.

- Zero configuration
- No predefined structures
- A minimal Hyperf distribution
- A single PHP file and you are already up and running

Personally, I am a die-hard fan of this simplicity. It is no accident that I made [Siler](https://github.com/leocavalcante/siler). Nano manages to bring all this simplicity while staying compatible with all\* (except Annotations) packages available for Hyperf and having Coroutines as *first-class citizens*.

*I admit that if I had known the Hyperf-Nano duo before, I might not have created Siler* 🤭

Alright, it looks pretty cool, but *talk is shit, show me the code*.

As mentioned earlier, Nano will not bother you with directory structures, so you can literally start with an empty directory:

```shell
mkdir hello-nano
cd hello-nano
```

Now bringing in Nano is as simple as any other PHP package. **If you write PHP and still do not know Composer, go back two spaces.**

```shell
composer require hyperf/nano
```

Now all you need is a single PHP file, like some street PHP, but with every kind of component for high-level applications available through a `composer install`, all of it running on Swoole Coroutines.

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

To start playing, just run:

```shell
php index.php start
```

And **voila**!

The default port is `9501`, so just access http://localhost:9501. To change the host and port, do it directly in the `AppFactory::create()` method:

```php
AppFactory::create('127.0.0.1', 8080);
```

Now just let your imagination take over, and you will still have full support for dependency injection *containers*, *ORMs* to access databases, an event dispatch system, and so on!

Do not forget to visit https://nano.hyperf.wiki/#/en/ and start exploring all the possibilities.

Cheers!
