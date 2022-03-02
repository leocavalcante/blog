---
title: Usando a Bref para executar de forma assíncrona Corrotinas da Swoole como funções na AWS Lambda
description: A Swoole estará entregando algo muito, muito legal, que é seu próprio CLI. Você já pode começar a utilizar usando o binário pré-compilado distribuído nos releases da Swoole em h...
date: "2022-03-02T12:53:25-03:00"
updated: "2022-03-02T12:53:25-03:00"
draft: false
tags:
    - aws
    - lambda
    - php
    - swoole
    - tech
url: /archive/medium/usando-a-bref-para-executar-de-forma-assincrona-corrotinas-da-swoole-como-funcoes-na-aws-lambda-3c7a1c7ee4ef/
cover: cover.png
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

![](cover.png)

A [Swoole](https://github.com/swoole/swoole-src) estará entregando algo muito, muito legal, que é seu próprio CLI. Você já pode começar a utilizar usando o binário pré-compilado distribuído nos releases da Swoole em [https://github.com/swoole/swoole-src/releases/tag/v4.8.7](https://github.com/swoole/swoole-src/releases/tag/v4.8.7).

O truque aqui, para este projeto, é que enviaremos o binário da Swoole CLI juntamente com a LambdaRuntime da [Bref](https://bref.sh/) para fornecer uma [Custom AWS Runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) que suporta a Swoole.

**Vamos começar?**

Crie um diretório para armazenar nossos arquivos:

```
mkdir swoole-lambda
cd swoole-lambda
```

Traga a IDE Helper para termos _autocomplete_ da Swoole no nosso editor:

```
composer require --dev swoole/ide-helper
```

Depois já podemos trazer a [Bref](https://bref.sh/):

```
composer require bref/bref
```

A [Bref](https://bref.sh/) nos fornecerá a abstração para nos comunicarmos com a _runtime_ da AWS Lambda. Podemos apenas chamá-lo em nosso arquivo bootstrap. O arquivo bootstrap é onde o _runtime_ Lambda iniciará a execução:

```
#!/opt/bin/swoole-cli
<?php

use Bref\Context\Context;
use Bref\Runtime\LambdaRuntime;
use Swoole\Coroutine;

require_once __DIR__ . '/vendor/autoload.php';

$runtime = LambdaRuntime::fromEnvironmentVariable('swoole-cli');
$handler = require $_ENV['LAMBDA_TASK_ROOT'] . '/handler.php';

Coroutine\run(static function () use ($runtime, $handler): void {
    while (true) {
        $runtime->processNextEvent($handler);
    }
});
```

O AWS Lambda moverá o que está em nosso diretório bin/ para /opt/bin, então o binário da Swoole CLI estará lá. É por isso que podemos criar nosso aplicativo Bootstrap PHP como um script auto-executável que usará um interpretador localizado nesse caminho.

Vamos baixa-lo:

```
wget https://github.com/swoole/swoole-src/releases/download/v4.8.7/swoole-cli-v4.8.7-linux-x64.tar.xz
tar -xf swoole-cli-v4.8.7-linux-x64.tar.xz
mkdir bin
mv swoole-cli bin/
rm swoole-cli-v4.8.7-linux-x64.tar.xz
```

#### **UPX ao resgate!**

148 MB de arquivo binário pode ser muito grande para uma função. Vamos usar a UPX para torná-lo menor:

```
upx -9 bin/swoole-cli
```

O -9 diz ao UPX para torná-lo o menor possível. Isso pode demorar um pouco, mas o **resultado final é um binário de 44 MB, é cerca de 30% do tamanho do arquivo original!**

Agora podemos criar com segurança nosso arquivo ZIP de _runtime_:

```
zip -r runtime.zip bootstrap bin
```

E carregue-lo na AWS Lambda como uma _layer_:

```
aws lambda publish-layer-version \
--layer-name swoole-runtime \
--zip-file fileb://runtime.zip \
--region us-east-1
```

Agora vamos fazer a mesma coisa nossos arquivos da _vendor/_:

```
zip -r vendor.zip vendor
```

E fazer o _upload_ também como uma _layer_:

```
aws lambda publish-layer-version \
--layer-name swoole-lambda-vendor \
--zip-file fileb://vendor.zip \
--region us-east-1
```

Com as _layers_ carregadas, estamos prontos para criar nossa função.

O arquivo handler.php que o bootstrap requer, contém nosso código de função:

```
<?php

declare(strict_types=1);

use Bref\Context\Context;

return static fn ($event, Context $context): string =>
    'Hello ' . ($event['name'] ?? 'world');
```

Agora vamos _zipa-la_:

```
zip -r function.zip handler.php
```

E cria-la na AWS:

```
aws lambda create-function \
--function-name swoole-lambda \
--handler handler.handler \
--zip-file fileb://function.zip \
--runtime provided \
--role arn:aws:iam::884320951759:role/swoole-lambda \
--region us-east-1 \
--layers arn:aws:lambda:us-east-1:884320951759:layer:swoole-runtime:1 \
arn:aws:lambda:us-east-1:884320951759:layer:swoole-lambda-vendor:1
```

**Ok, rufem os tambores!**

Vamos testar:

```
aws lambda invoke \
--function-name swoole-lambda \
--region us-east-1 \
--log-type Tail \
--query 'LogResult' \
--output text \
--payload $(echo '{"name": "Swoole"}' | base64) output.txt | base64 --decode
```

A saída deve ser algo como:

```
START RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97 Version: $LATEST
END RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97
REPORT RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97  Duration: 3.67 ms       Billed Duration: 4 ms   Memory Size: 128 MB     Max Memory Used: 115 MB
```

Vamos ver o resultado:

```
cat output.txt
"Hello Swoole"
```

**Isso é tudo pessoal!**

A [Bref](https://bref.sh/) abstrai todo o trabalho de se comunicar com a interface da _runtime_ da AWS Lambda. Internamente ele usa curl\_\* [**que Swoole pode conectar e fazer de forma assíncrona!**](https://github.com/swoole/swoole-src)

E claro, não precisa mencionar, o projeto Swoole CLI também arrasa muito nos trazendo um interpretador PHP com Swoole embutido (compilado estaticamente).
