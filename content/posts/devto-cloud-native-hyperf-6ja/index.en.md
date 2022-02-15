---
title: Cloud-native Hyperf
description: Originally posted by @Reasno at guxi.me/posts/cloudnative-hyperf     Hyperf officially provides...
date: "2022-02-15T20:31:05-03:00"
updated: ""
draft: false
tags:
    - cloud
    - hyperf
    - php
    - swoole
url: /en/archive/devto/cloud-native-hyperf-6ja/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Originally posted by [@Reasno](https://twitter.com/Reasno_g) at [guxi.me/posts/cloudnative-hyperf](https://guxi.me/posts/cloudnative-hyperf)

---

Hyperf officially provides container images and the configuration options are very open. Deploying Hyperf in the cloud itself is not complicated. Let's take Kubernetes as an example to make some modifications to the default skeleton package of Hyperf so that it can run gracefully on Kubernetes. This article is not an introduction to Kubernetes and readers need to have a certain understanding of Kubernetes.

## Life cycle
After a container is started on Kubernetes, it performs two checks on the container: **Liveness Probe** and **Readiness Probe**. If the Liveness Probe fails, the container will be restarted, and if the Readiness Probe fails, the service will be temporarily removed from the discovery list. When Hyperf is started as an HTTP web server, we only need to add two routes.

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

Configure on the deployment of Kubernetes:

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

Of course here we simply return 'ok', obviously we can't really check the health. The actual inspection should consider the specific business scenarios and the resources that the business depends on. For example, for heavy database services, we can check the connection pool of the database, and if the connection pool is full, temporarily return the status code 503 in the Readiness Probe.

When the service is destroyed by Kubernetes, it will send the `SIGTERM` signal first. The process has `terminationGracePeriodSeconds` this long (default 60 seconds) to terminate itself. If the time is up, Kubernetes will send a `SIGINT` signal to forcibly kill the process. Swoole itself can correctly respond to `SIGTERM` to end the service, and will not lose any running connections under normal circumstances. In actual production, if Swoole does not respond to `SIGTERM` and exits, it is likely that the timer registered by the server has not been cleaned up. We can clean up the timer at `OnWorkerExit` to ensure a smooth exit.

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

## Operating mode
Swoole Server includes two operating modes. Single-threaded mode (`SWOOLE_BASE`) and process mode (`SWOOLE_PROCESS`).

The Hyperf official skeleton package defaults to Process mode. In traditional service deployment, Process mode will help us manage processes. In Kubernetes deployment, Kubernetes and Kubernetes' Ingress or Sidecar have already undertaken some functions such as pulling, balancing and connection maintenance. Using Process is slightly redundant.

Docker officially encourages the _"one process per container"_ approach. Here we use Base mode and only start one process (`worker_num=1`).

The Swoole official website defines the advantages of Base mode as:

1. Base mode has no IPC overhead and better performance.
2. The BASE mode code is simpler and less error-prone.

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

After setting up one process per container, our expansion and contraction can be more delicate. Imagine if there are 16 processes in a container, then the number of processes after our expansion can only be a multiple of 16, and each container has one process, we can set the total number of processes to any natural number.

Since there is only one process per container, here we limit each container to use at most one core.

```yaml
resources:
  requests:
    cpu: "1"
  limits:
    cpu: "1"
```

Then we configure the Horizontal Pod Autoscaler to automatically scale according to service pressure.

```bash
# Minimum 1 process, maximum 100 processes, target CPU usage 50%
kubectl autoscale deployment hyperf-demo --cpu-percent=50 --min=1 --max=100
```

## Log processing
Best practice for Docker containers is to print logs to `stdout` and `stderr`. Hyperf logs are divided into system logs and application logs. The system logs have been printed to the standard output, and the application logs are printed to the runtime folder by default. This is obviously not flexible enough in a container environment. We print both to standard output.

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

A closer look at the above configuration will reveal that we have done different processing for different environment variables.

First, we output JSON structured logs in the production environment, because log collection tools such as FluentBit and Filebeat can natively parse JSON logs, distribute, filter, and modify them to avoid complex grok regular matching. In a development environment, JSON logs are not so friendly, and readability plummets when escaping is involved. So in the development environment we still use LineFormatter to output logs.

Second, we output a lot of logs in the development environment, and in the production environment, we need to control the number of logs to avoid clogging the log collection tool. If the log is eventually easy to write to Elasticsearch, it is even more important to control the writing speed. In the production environment, we recommend that only logs above WARNING be enabled by default.

According to the introduction of the official documentation, we also hand over the logs printed by the framework to Monolog for processing.

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

## File handling
Stateful applications cannot be scaled arbitrarily. The common state of PHP application is nothing more than Session, log, file upload, etc. Session can be stored in Redis. The log has been introduced in the previous section. This section introduces the processing of files.

It is recommended to upload files to the cloud in the form of object storage. Alibaba Cloud, Qiniu Cloud, etc. are all common suppliers. Private deployment solutions also include MinIO, Ceph, etc. To avoid vendor lock-in, it is recommended to use a unified abstraction layer instead of relying directly on vendor-provided SDKs. `league/flysystem` is a common choice for many mainstream frameworks including Laravel. Here we introduce the `League\Flysystem` package and connect MinIO storage through the aws S3 API.

```bash
composer require league/flysystem
composer require league/flysystem-aws-s3-v3
```

Create a factory class and bind the relationship according to the official documentation of Hyperf DI.

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

Let's create a new `config/autoload/file.php` in the way Hyperf is used to, and configure the S3 key and other information:

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

Like the log, when developing and debugging, we use the Runtime folder for uploading, and in the production environment, we upload pictures to MinIO. To upload to Alibaba Cloud in the future, just install the league/flysystem Alibaba Cloud adapter:

```bash
composer require aliyuncs/aliyun-oss-flysystem
```

And rewrite FileSystemFactory as needed.

## Track and monitor
Link tracking and service monitoring itself are not functions provided by Kubernetes, but because the technology stacks in the cloud native panorama can cooperate very well with each other, it is usually recommended to use them together.

Hyperf link tracing documentation: [hyperf.wiki/2.2/#/zh-cn/tracer](https://hyperf.wiki/2.2/)

Hyperf service monitoring documentation: [hyperf.wiki/2.2/#/zh-cn/metric](https://hyperf.wiki/2.2/)

If you have configured base mode and use a process, you do not need to start a separate monitoring process when monitoring the service. Add the following routes to the Controller:

```php
<?php
// Bind the /metrics route here
public function metrics(CollectorRegistry $registry)
{
    $renderer = new RenderTextFormat();
    return $renderer->render($registry->getMetricFamilySamples());
}
```

If the Prometheus you are using supports discovering crawling targets from service annotations, just add Prometheus annotations to Service.

```yaml
kind: Service
metadata:
  annotations:
    prometheus.io/port: "9501"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
```

If you use Nginx Ingress, you can configure Opentracing to be enabled. ( nginx ingress documentation )

First configure the Tracer used in the Nginx Ingress Configmap.

```yaml
zipkin-collector-host: zipkin.default.svc.cluster.local
jaeger-collector-host: jaeger-agent.default.svc.cluster.local
datadog-collector-host: datadog-agent.default.svc.cluster.local
```

Then open opentracing in the Ingress annotation.

```yaml
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/enable-opentracing: "true"
```

In this way, the link between Nginx Ingress and Hyperf can be opened up.

## Complete example
A complete skeleton package can be found on my GitHub: https://github.com/Reasno/cloudnative-hyperf

There are actually many ways to deploy Kubernetes. It is impossible for any skeleton package to be suitable for all situations.
