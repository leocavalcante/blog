---
title: Hyperf nativo da nuvem
description: Publicado originalmente por @Reasno em guxi.me/posts/cloudnative-hyperf     O Hyperf fornece oficialmente...
date: "2022-02-15T20:31:05-03:00"
updated: ""
draft: false
tags:
    - cloud
    - hyperf
    - php
    - kubernetes
    - architecture
url: /archive/devto/cloud-native-hyperf-6ja/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Publicado originalmente por [@Reasno](https://twitter.com/Reasno_g) em [guxi.me/posts/cloudnative-hyperf](https://guxi.me/posts/cloudnative-hyperf)

---

O Hyperf fornece oficialmente imagens de contêiner, e as opções de configuração são bem abertas. Fazer o deploy do Hyperf na nuvem em si não é complicado. Vamos usar Kubernetes como exemplo e fazer algumas modificações no pacote esqueleto padrão do Hyperf para que ele rode de forma elegante no Kubernetes. Este artigo não é uma introdução ao Kubernetes, então quem lê precisa ter algum conhecimento sobre Kubernetes.

## Ciclo de vida
Depois que um contêiner é iniciado no Kubernetes, ele executa duas verificações no contêiner: **Liveness Probe** e **Readiness Probe**. Se a Liveness Probe falhar, o contêiner será reiniciado; se a Readiness Probe falhar, o serviço será removido temporariamente da lista de descoberta. Quando o Hyperf é iniciado como um servidor web HTTP, só precisamos adicionar duas rotas.

```php
<?php

namespace App\Controller;

class HealthCheckController extends AbstractController
{
    public function liveness()
    {
        return 'ok';
    }

    public function readiness()
    {
        return 'ok';
    }
}
```

```php
<?php

// in config/Routes.php
Router::addRoute(['GET', 'HEAD'], '/liveness', 'App\Controller\HealthCheckController@liveness');
Router::addRoute(['GET', 'HEAD'], '/readiness', 'App\Controller\HealthCheckController@readiness');
```

Configure no deployment do Kubernetes:

```yaml
livenessProbe:
  httpGet:
    path: /liveness
    port: 9501
  failureThreshold: 1
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /readiness
    port: 9501
  failureThreshold: 1
  periodSeconds: 10
```

É claro que aqui simplesmente retornamos 'ok', o que obviamente não verifica a saúde de verdade. A inspeção real deve considerar os cenários de negócio específicos e os recursos dos quais o negócio depende. Por exemplo, para serviços que usam banco de dados intensivamente, podemos verificar o pool de conexões do banco e, se o pool estiver cheio, retornar temporariamente o status code 503 na Readiness Probe.

Quando o serviço é destruído pelo Kubernetes, ele envia primeiro o sinal `SIGTERM`. O processo tem esse tempo definido por `terminationGracePeriodSeconds` (60 segundos por padrão) para se encerrar. Se o tempo acabar, o Kubernetes enviará um sinal `SIGINT` para matar o processo à força. O próprio Swoole consegue responder corretamente ao `SIGTERM` para encerrar o serviço e, em circunstâncias normais, não perderá nenhuma conexão em andamento. Em produção, se o Swoole não responder ao `SIGTERM` e sair, é provável que algum timer registrado pelo servidor não tenha sido limpo. Podemos limpar o timer em `OnWorkerExit` para garantir um encerramento suave.

```php
<?php
// config/autoload/server.php
// ...
'callbacks' => [
    SwooleEvent::ON_BEFORE_START => [Hyperf\Framework\Bootstrap\ServerStartCallback::class, 'beforeStart'],
    SwooleEvent::ON_WORKER_START => [Hyperf\Framework\Bootstrap\WorkerStartCallback::class, 'onWorkerStart'],
    SwooleEvent::ON_PIPE_MESSAGE => [Hyperf\Framework\Bootstrap\PipeMessageCallback::class, 'onPipeMessage'],
    SwooleEvent::ON_WORKER_EXIT => function () {
        Swoole\Timer::clearAll();
    },
],
// ...
```

## Modo de operação
O Swoole Server inclui dois modos de operação: modo single-threaded (`SWOOLE_BASE`) e modo de processo (`SWOOLE_PROCESS`).

O pacote esqueleto oficial do Hyperf usa o modo Process por padrão. Em deployments tradicionais de serviços, o modo Process ajuda a gerenciar processos. Em um deployment no Kubernetes, o Kubernetes e o Ingress ou Sidecar do Kubernetes já assumem algumas funções, como pull, balanceamento e manutenção de conexões. Usar Process acaba sendo um pouco redundante.

O Docker incentiva oficialmente a abordagem _"um processo por contêiner"_. Aqui usamos o modo Base e iniciamos apenas um processo (`worker_num=1`).

O site oficial do Swoole define as vantagens do modo Base como:

1. O modo Base não tem overhead de IPC e oferece melhor desempenho.
2. O código no modo BASE é mais simples e menos propenso a erros.

```php
<?php
// config/autoload/server.php
// ...
'mode' => SWOOLE_BASE,
// ...
'settings' => [
    'enable_coroutine' => true,
    'worker_num' => 1,
    'pid_file' => BASE_PATH . '/runtime/hyperf.pid',
    'open_tcp_nodelay' => true,
    'max_coroutine' => 100000,
    'open_http2_protocol' => true,
    'max_request' => 100000,
    'socket_buffer_size' => 2 * 1024 * 1024,
],
// ...
```

Depois de configurar um processo por contêiner, nossa expansão e contração podem ser mais granulares. Imagine que existam 16 processos em um contêiner; nesse caso, o número de processos depois da expansão só poderia ser múltiplo de 16. Com um processo por contêiner, podemos definir o número total de processos como qualquer número natural.

Como existe apenas um processo por contêiner, aqui limitamos cada contêiner a usar no máximo um core.

```yaml
resources:
  requests:
    cpu: "1"
  limits:
    cpu: "1"
```

Depois configuramos o Horizontal Pod Autoscaler para escalar automaticamente de acordo com a pressão do serviço.

```bash
# Minimum 1 process, maximum 100 processes, target CPU usage 50%
kubectl autoscale deployment hyperf-demo --cpu-percent=50 --min=1 --max=100
```

## Processamento de logs
A melhor prática para contêineres Docker é imprimir logs em `stdout` e `stderr`. Os logs do Hyperf são divididos em logs de sistema e logs de aplicação. Os logs de sistema já são impressos na saída padrão, e os logs de aplicação são impressos por padrão na pasta runtime. Isso obviamente não é flexível o suficiente em um ambiente de contêiner. Vamos imprimir ambos na saída padrão.

```php
<?php
// config/autoload/logger.php
return [
    'default' => [
        'handler' => [
            'class' => Monolog\Handler\ErrorLogHandler::class,
            'constructor' => [
                'messageType' => Monolog\Handler\ErrorLogHandler::OPERATING_SYSTEM,
                'level' => env('APP_ENV') === 'prod'
                ? Monolog\Logger::WARNING
                : Monolog\Logger::DEBUG,
            ],
        ],
        'formatter' => [
            'class' => env('APP_ENV') === 'prod'
            ? Monolog\Formatter\JsonFormatter::class
            : Monolog\Formatter\LineFormatter::class,
        ],
        'PsrLogMessageProcessor' => [
            'class' => Monolog\Processor\PsrLogMessageProcessor::class,
        ],
    ],
];
```

Um olhar mais atento para a configuração acima mostra que fizemos processamentos diferentes para variáveis de ambiente diferentes.

Primeiro, geramos logs estruturados em JSON no ambiente de produção, porque ferramentas de coleta de logs como FluentBit e Filebeat conseguem fazer parse nativo de logs JSON, distribuí-los, filtrá-los e modificá-los sem depender de combinações complexas com grok. Em um ambiente de desenvolvimento, logs JSON não são tão amigáveis, e a legibilidade despenca quando há escapes envolvidos. Por isso, no ambiente de desenvolvimento ainda usamos LineFormatter para gerar logs.

Segundo, no ambiente de desenvolvimento geramos muitos logs; no ambiente de produção, precisamos controlar a quantidade de logs para evitar congestionar a ferramenta de coleta. Se o log eventualmente for gravado no Elasticsearch, controlar a velocidade de escrita é ainda mais importante. No ambiente de produção, recomendamos habilitar por padrão apenas logs acima de WARNING.

De acordo com a introdução da documentação oficial, também entregamos ao Monolog o processamento dos logs impressos pelo framework.

```php
<?php
namespace App\Provider;

use Hyperf\Logger\LoggerFactory;
use Psr\Container\ContainerInterface;

class StdoutLoggerFactory
{
    public function __invoke(ContainerInterface $container)
    {
        $factory = $container->get(LoggerFactory::class);
        return $factory->get('Sys', 'default');
    }
}
```

```php
<?php
// config/autoload/dependencies.php
return [
	Hyperf\Contract\StdoutLoggerInterface::class => App\Provider\StdoutLoggerFactory::class,
];
```

## Tratamento de arquivos
Aplicações stateful não podem ser escaladas arbitrariamente. O estado comum de uma aplicação PHP geralmente se resume a Session, logs, upload de arquivos etc. Session pode ser armazenada no Redis. Os logs foram apresentados na seção anterior. Esta seção apresenta o processamento de arquivos.

Recomenda-se fazer upload de arquivos para a nuvem na forma de armazenamento de objetos. Alibaba Cloud, Qiniu Cloud etc. são fornecedores comuns. Soluções de deployment privado também incluem MinIO, Ceph etc. Para evitar vendor lock-in, recomenda-se usar uma camada de abstração unificada em vez de depender diretamente dos SDKs fornecidos pelos vendors. `league/flysystem` é uma escolha comum em muitos frameworks populares, incluindo Laravel. Aqui introduzimos o pacote `League\Flysystem` e conectamos o armazenamento MinIO por meio da API aws S3.

```bash
composer require league/flysystem
composer require league/flysystem-aws-s3-v3
```

Crie uma classe factory e vincule a relação de acordo com a documentação oficial de DI do Hyperf.

```php
<?php
namespace App\Provider;

use Aws\S3\S3Client;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Guzzle\CoroutineHandler;
use League\Flysystem\Adapter\Local;
use League\Flysystem\AwsS3v3\AwsS3Adapter;
use League\Flysystem\Config;
use League\Flysystem\Filesystem;
use Psr\Container\ContainerInterface;

class FileSystemFactory
{
    public function __invoke(ContainerInterface $container)
    {
        $config = $container->get(ConfigInterface::class);
        if ($config->get('app_env') === 'dev') {
            return new Filesystem(new Local(__DIR__ . '/../../runtime'));
        }
        $options = $container->get(ConfigInterface::class)->get('file');
        $adapter = $this->adapterFromArray($options);
        return new Filesystem($adapter, new Config($options));
    }

    private function adapterFromArray(array $options): AwsS3Adapter
    {
    	// 协程化S3客户端
        $options = array_merge($options, ['http_handler' => new CoroutineHandler()]);
        $client = new S3Client($options);
        return new AwsS3Adapter($client, $options['bucket_name'], '', ['override_visibility_on_copy' => true]);
    }
}
```

```php
<?php
// config/autoload/dependencies.php
return [
	Hyperf\Contract\StdoutLoggerInterface::class => App\Provider\StdoutLoggerFactory::class,
	League\Flysystem\Filesystem::class => App\Provider\FileSystemFactory::class,
];
```

Vamos criar um novo `config/autoload/file.php` do jeito que o Hyperf costuma usar e configurar a chave do S3 e outras informações:

```
<?php
// config/autoload/file.php
return [
    'credentials' => [
        'key' => env('S3_KEY'),
        'secret' => env('S3_SECRET'),
    ],
    'region' => env('S3_REGION'),
    'version' => 'latest',
    'bucket_endpoint' => false,
    'use_path_style_endpoint' => true,
    'endpoint' => env('S3_ENDPOINT'),
    'bucket_name' => env('S3_BUCKET'),
];
```

Assim como nos logs, ao desenvolver e depurar usamos a pasta Runtime para uploads e, no ambiente de produção, fazemos upload das imagens para o MinIO. Para fazer upload para a Alibaba Cloud no futuro, basta instalar o adaptador Alibaba Cloud do league/flysystem:

```bash
composer require aliyuncs/aliyun-oss-flysystem
```

E reescrever FileSystemFactory conforme necessário.

## Rastreamento e monitoramento
O rastreamento de chamadas e o monitoramento de serviços em si não são funções fornecidas pelo Kubernetes, mas, como as pilhas de tecnologia no panorama cloud native conseguem cooperar muito bem entre si, geralmente é recomendado usá-las em conjunto.

Documentação de rastreamento do Hyperf: [hyperf.wiki/2.2/#/zh-cn/tracer](https://hyperf.wiki/2.2/)

Documentação de monitoramento de serviços do Hyperf: [hyperf.wiki/2.2/#/zh-cn/metric](https://hyperf.wiki/2.2/)

Se você configurou o modo base e usa um processo, não precisa iniciar um processo de monitoramento separado ao monitorar o serviço. Adicione as rotas abaixo ao Controller:

```php
<?php
// Bind the /metrics route here
public function metrics(CollectorRegistry $registry)
{
    $renderer = new RenderTextFormat();
    return $renderer->render($registry->getMetricFamilySamples());
}
```

Se o Prometheus que você usa oferece suporte à descoberta de targets de coleta por anotações de serviço, basta adicionar as anotações do Prometheus ao Service.

```yaml
kind: Service
metadata:
  annotations:
    prometheus.io/port: "9501"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
```

Se você usa Nginx Ingress, pode configurar a ativação do Opentracing. (documentação do nginx ingress)

Primeiro configure o Tracer usado no Configmap do Nginx Ingress.

```yaml
zipkin-collector-host: zipkin.default.svc.cluster.local
jaeger-collector-host: jaeger-agent.default.svc.cluster.local
datadog-collector-host: datadog-agent.default.svc.cluster.local
```

Depois habilite opentracing na annotation do Ingress.

```yaml
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/enable-opentracing: "true"
```

Dessa forma, a ligação entre o Nginx Ingress e o Hyperf pode ser aberta.

## Exemplo completo
Um pacote esqueleto completo pode ser encontrado no meu GitHub: https://github.com/Reasno/cloudnative-hyperf

Na prática, existem muitas formas de fazer deploy no Kubernetes. É impossível que qualquer pacote esqueleto seja adequado para todas as situações.
