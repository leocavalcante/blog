---
title: Using Bref's LambdaRuntime to Asynchronously Run Swoole Coroutines as Functions on AWS
description: Swoole will be shipping something really-really cool that is it's own CLI. You can start playing with...
date: "2022-02-28T22:17:19-03:00"
updated: "2022-03-01T00:17:19-03:00"
draft: false
tags:
    - cloud
    - php
    - async
    - swoole
    - coroutines
url: /en/archive/devto/using-brefs-lambaruntime-to-asynchronously-run-swoole-coroutines-as-functions-on-aws-1icm/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Swoole will be shipping something really-really cool that is it's own CLI. You can start playing with it using the pre-compiled binary distributed under Swoole's releases at https://github.com/swoole/swoole-src/releases/tag/v4.8.7.

The trick here, for this project, is: **we will be shipping Swoole CLI binary along side with [Bref's `LambdaRuntime`](https://github.com/brefphp/bref/blob/master/src/Runtime/LambdaRuntime.php) to provide a [custom AWS lambda runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) that is Swoole powered**.

Let's get started.

Create a directory to hold our files:
```shell
mkdir swoole-lambda
cd swoole-lambda
```

Bring Swoole's IDE helper so we can have code completions in our editor:
```shell
composer require --dev swoole/ide-helper
```

Then we can already bring [Bref](https://github.com/brefphp/bref) to the playground:
```shell
composer require bref/bref
```

[Bref](https://bref.sh/) will provide us the abstraction to communicate with AWS Lambda runtime. We can just call it at our bootstrap file. The bootstrap file is where the lambda runtime will start the invocation:
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

AWS Lambda will move what is in our `bin/` directory to `/opt/bin`, so our Swoole CLI will be there. That is why we can create our Bootstrap PHP application as a self-executing script that will be using an interpreter located at that path.

Let's grab it:
```shell
wget https://github.com/swoole/swoole-src/releases/download/v4.8.7/swoole-cli-v4.8.7-linux-x64.tar.xz
tar -xf swoole-cli-v4.8.7-linux-x64.tar.xz
mkdir bin
mv swoole-cli bin/
rm swoole-cli-v4.8.7-linux-x64.tar.xz
```

**[UPX](https://upx.github.io/) to the rescue!** 148MB can be too large for a function. Let's use UPX to make it smaller:
```bash
upx -9 bin/swoole-cli
```
The `-9` tells [UPX](https://upx.github.io/) to make it as small as possible. This can take a while, but the **final result is a 44MB binary, it is about 30% of the original file size!**

Now we can safely create our runtime ZIP file:
```shell
zip -r runtime.zip bootstrap bin
```

And upload it to AWS Lambda as a layer:
```shell
aws lambda publish-layer-version \
--layer-name swoole-runtime \
--zip-file fileb://runtime.zip \
--region us-east-1
```

Now lets zip our vendor files:
```shell
zip -r vendor.zip vendor
```

And upload it as a layer as well:
```shell
aws lambda publish-layer-version \
--layer-name swoole-lambda-vendor \
--zip-file fileb://vendor.zip \
--region us-east-1
```

With the layers uploaded, we are ready to create our function.

The `handler.php` file which `bootstrap` requires, holds our function code:
```php
<?php

declare(strict_types=1);

use Bref\Context\Context;

return static fn ($event, Context $context): string =>
    'Hello ' . ($event['name'] ?? 'world');

```

Zip it:
```bash
zip -r function.zip handler.php
```

And create:
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

**Ok, roll the drums.**

Let's test it:
```bash
aws lambda invoke \
--function-name swoole-lambda \
--region us-east-1 \
--log-type Tail \
--query 'LogResult' \
--output text \
--payload $(echo '{"name": "Swoole"}' | base64) output.txt | base64 --decode
```

The output should be something like:
```text
START RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97 Version: $LATEST
END RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97
REPORT RequestId: eaa39e02-b833-4f06-b18d-7e9a5b603a97  Duration: 3.67 ms       Billed Duration: 4 ms   Memory Size: 128 MB     Max Memory Used: 115 MB
```

Let's see the results:
```bash
cat output.txt
"Hello Swoole"
```

**That is all folks!**

[Bref](https://bref.sh/) abstracts way all the hassle about interfacing with [AWS Lambda runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html). Internally it uses `curl_*` which [**Swoole can hook up and make asynchronously!**](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html)

And of course, don't need to mention, the Swoole CLI project also rocks a lot bringing us a PHP interpreter with Swoole built-in (statically compiled).
