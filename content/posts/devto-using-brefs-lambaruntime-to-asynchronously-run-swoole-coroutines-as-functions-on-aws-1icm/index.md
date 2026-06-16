---
title: Usando o LambdaRuntime do Bref para executar corrotinas Swoole de forma assíncrona como funções na AWS
description: O Swoole vai lançar algo muito, muito legal, que é sua própria CLI. Você já pode começar a brincar com...
date: "2022-02-28T22:17:19-03:00"
updated: "2022-03-01T00:17:19-03:00"
draft: false
tags:
    - cloud
    - php
    - async
    - swoole
    - coroutines
url: /archive/devto/using-brefs-lambaruntime-to-asynchronously-run-swoole-coroutines-as-functions-on-aws-1icm/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

O Swoole vai lançar algo muito, muito legal: sua própria CLI. Você já pode começar a brincar com ela usando o binário pré-compilado distribuído nas releases do Swoole em https://github.com/swoole/swoole-src/releases/tag/v4.8.7.

O truque aqui, para este projeto, é: **vamos distribuir o binário da Swoole CLI junto com o [`LambdaRuntime` do Bref](https://github.com/brefphp/bref/blob/master/src/Runtime/LambdaRuntime.php) para fornecer um [runtime AWS Lambda customizado](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) movido por Swoole**.

Vamos começar.

Crie um diretório para guardar nossos arquivos:
```shell
mkdir swoole-lambda
cd swoole-lambda
```

Traga o IDE helper do Swoole para termos autocomplete de código no nosso editor:
```shell
composer require --dev swoole/ide-helper
```

Então já podemos trazer o [Bref](https://github.com/brefphp/bref) para o playground:
```shell
composer require bref/bref
```

O [Bref](https://bref.sh/) nos dará a abstração para nos comunicarmos com o runtime da AWS Lambda. Podemos simplesmente chamá-lo no nosso arquivo de bootstrap. O arquivo de bootstrap é onde o runtime da lambda iniciará a invocação:
```php
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

A AWS Lambda moverá o que estiver no nosso diretório `bin/` para `/opt/bin`, então nossa Swoole CLI estará lá. É por isso que podemos criar nossa aplicação PHP de Bootstrap como um script autoexecutável que usará um interpretador localizado nesse caminho.

Vamos baixá-lo:
```shell
wget https://github.com/swoole/swoole-src/releases/download/v4.8.7/swoole-cli-v4.8.7-linux-x64.tar.xz
tar -xf swoole-cli-v4.8.7-linux-x64.tar.xz
mkdir bin
mv swoole-cli bin/
rm swoole-cli-v4.8.7-linux-x64.tar.xz
```

**[UPX](https://upx.github.io/) ao resgate!** 148 MB pode ser grande demais para uma função. Vamos usar UPX para deixá-lo menor:
```bash
upx -9 bin/swoole-cli
```
O `-9` diz ao [UPX](https://upx.github.io/) para deixá-lo o menor possível. Isso pode demorar um pouco, mas o **resultado final é um binário de 44 MB, cerca de 30% do tamanho do arquivo original!**

Agora podemos criar com segurança nosso arquivo ZIP do runtime:
```shell
zip -r runtime.zip bootstrap bin
```

E enviá-lo para a AWS Lambda como uma layer:
```shell
aws lambda publish-layer-version \
--layer-name swoole-runtime \
--zip-file fileb://runtime.zip \
--region us-east-1
```

Agora vamos compactar nossos arquivos vendor:
```shell
zip -r vendor.zip vendor
```

E enviá-lo também como uma layer:
```shell
aws lambda publish-layer-version \
--layer-name swoole-lambda-vendor \
--zip-file fileb://vendor.zip \
--region us-east-1
```

Com as layers enviadas, estamos prontos para criar nossa função.

O arquivo `handler.php`, exigido pelo `bootstrap`, contém o código da nossa função:
```php
<?php

declare(strict_types=1);

use Bref\Context\Context;

return static fn ($event, Context $context): string =>
    'Hello ' . ($event['name'] ?? 'world');

```

Compacte:
```bash
zip -r function.zip handler.php
```

E crie:
```bash
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

**Ok, rufem os tambores.**

Vamos testá-la:
```bash
aws lambda invoke \
--function-name swoole-lambda \
--region us-east-1 \
--log-type Tail \
--query 'LogResult' \
--output text \
--payload $(echo '{"name": "Swoole"}' | base64) output.txt | base64 --decode
```

A saída deve ser algo como:
```text
START RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97 Version: $LATEST
END RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97
REPORT RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97  Duration: 3.67 ms       Billed Duration: 4 ms   Memory Size: 128 MB     Max Memory Used: 115 MB
```

Vamos ver os resultados:
```bash
cat output.txt
"Hello Swoole"
```

**É isso, pessoal!**

O [Bref](https://bref.sh/) abstrai todo o trabalho de interface com o [runtime da AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html). Internamente, ele usa `curl_*`, que o [**Swoole consegue interceptar e tornar assíncrono!**](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html)

E, claro, nem preciso dizer que o projeto Swoole CLI também é excelente por nos trazer um interpretador PHP com Swoole embutido (compilado estaticamente).
