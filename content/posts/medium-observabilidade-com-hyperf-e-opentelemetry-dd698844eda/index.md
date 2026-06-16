---
title: Observabilidade com Hyperf e OpenTelemetry
description: No PicPay, para melhorar a escalabilidade de nossas aplicações feitas em PHP, nós utilizamos a _Swoole_ como _runtime_ de alta-performance tornando as aplicações assíncronas e n...
date: "2022-03-22T15:44:16-03:00"
updated: "2022-03-22T15:44:16-03:00"
draft: false
tags:
    - observability
    - php
    - architecture
    - hyperf
    - cloud
url: /archive/medium/observabilidade-com-hyperf-e-opentelemetry-dd698844eda/
cover: cover.png
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

![](cover.png)

No PicPay, para melhorar a escalabilidade de nossas aplicações feitas em PHP, nós utilizamos a _Swoole_ como _runtime_ de alta-performance tornando as aplicações assíncronas e não-bloqueantes.

Começar a utilizar a _Swoole_ trouxe alguns desafios, um deles é o da observabilidade, vamos entender mais a frente.

![](media/image-01.jpg)

Photo by [Davyn Ben](https://unsplash.com/@davynben) on [Unsplash](https://unsplash.com)

### Observabilidade

Observabilidade é a metodologia que o mercado de microsserviços e _cloud-native_ explora para monitorar as aplicações, saber como os recursos estão sendo utilizados, se a aplicação está entregando o que ela se propõe fazer e se tiverem erros, e como identificá-los.

Para isso, são definidos três pilares (e talvez um quarto):

#### Métricas

Métricas são medidas de avaliação quantitativa comumente usadas para comparar e acompanhar o desempenho ou a produção. **Quantas vezes aconteceu.**

#### Traces

Conjunto de _Spans_, são a coleção de lugares por onde o clico de vida de uma transação passou. **Onde aconteceu.**

#### Logs

Informações sobre qual era o atual contexto no momento que algo aconteceu durante o clico de vida de uma transação. **O que aconteceu.**

#### **Eventos?**

É cada vez mais comum separar _logs_ de eventos e muitas pessoas veem como o quarto pilar da observabilidade. Eventos são informações sobre regras de negócio. Dados personalizados sobre a experiência de um determinado fluxo de dados. A maior diferença para os _logs_ é que aqui não ficam dados sobre infraestrutura.

### Hyperf

_Hyperf_ é o _framework web_ que adotamos para as aplicações PHP em _Swoole_. Os pontos que nos levaram a utilizá-lo foi por ele ter corrotinas como cidadãs de primeira-classe. O _Hyperf_ foi feito para a _Swoole_, ele não foi adaptado para a _Swoole_ como seria com outros _frameworks_ de mercado como _Laravel_, _Symfony_ e _Laminas_.

Todos os componentes dentro dele estão preparados para trabalhar com corrotinas usando _pool_ de conexões, evitando estado global utilizando os contextos das corrotinas e evitando ao máximo _memory-leaks_ já que agora a memória do processo não vai ser limpa a cada requisição e com isso também vem o cuidado de não fazer os dados de um requisição afetar a outra.

Resumidamente, o _Hyperf_ está preparado para trabalhar da forma _stateful_ que é totalmente o contrário da forma stateless do PHP-FPM tradicional.

#### Feito para microsserviços

Outro ponto muito legal que corroborou com nossa escolha, é a forma como o foco do _Hyperf_ fica em microsserviços. Ele não se preocupa com coisas como _views_ e sessões, coisas que são mais utilizadas na construção de sites.

No lugar, o Hyperf entrega componentes que foram pensados em microsserviços e no mundo _cloud_, coisas como: _circuit-break_, _rate-limit_, _service-discovery_, _remote-config_, gRPC etc.

**E, claro, junto desses componentes _cloud-native_ focados em microsserviços, tem os componentes para Observabilidade.**

#### Problemas com APMs

Geralmente a observabilidade de aplicações é feita de forma trivial através de APMs. O provedor do serviço de monitoramento, por exemplo o _New Relic_, fornece um APM que pode ser adicionado ao servidor para rodar junto com a aplicação e ele faz a instrumentação do que está acontecendo.

Os APMs fazem isso utilizando uma técnica chamada _Monkey Patch_, essa técnica é uma forma de adicionar comportamento em tempo de execução. Quando você chama o cURL através das funções curl\_, por exemplo, na verdade você tá chamando a biblioteca da _New Relic_ que, por sua vez, chama a cURL padrão do PHP, mas no meio disso adiciona o comportamento que faz a instrumentação.

A Swoole tem uma _feature_ chamada _Runtime Hooks_, que faz com que recursos atuais do PHP, como o cURL, PDO, Redis etc funcionem de forma assíncrona, dentro de seu _event-loop_ e a _Swoole_ faz isso utilizando a mesma técnica de _Monkey Patch_, sobrescrevendo as funções nativas do PHP para adicionar esse comportamento novo.

Aí vem o problema: duas extensões, cada uma querendo fazer o _monkey patch_, a sobrescrita das mesmas funções nativas do PHP. Elas entram em conflito e no fim nenhuma funciona.

### OpenTelemetry

Uma das formas que encontramos para resolver esse problema com os APMs foi fazer a instrumentação utilizando o próprio PHP ao invés de APMs. Deu super certo, funcionou, felizmente a _New Relic_ tem uma API REST, na verdade APIs REST que são exatamente 1:1 para os pilares, uma API para métricas, para traces e para eventos. Fazíamos a instrumentação de forma manual e enviávamos os dados para essas APIs.

O problema disso é que houve muita mistura entre código de regras de negócio e código de instrumentação, as classes e o métodos ganhavam mais linhas de coisas que não tinham relação direta.

De qualquer forma, foi por meio dessa ideia de instrumentar com o PHP que descobrimos o **OpenTelemetry**.

O projeto _OTel_ é a fusão dos projetos _OpenTracing_ e _OpenCencus_, ou seja, já existiam iniciativas para Observabilidade utilizando formatos abertos. O _OpenTelemetry_ juntou essa galera para uma fundação e organização.

Já existiam projetos para o PHP de _OpenTracing_ que geravam formatos abertos como _Jaeger_ e _StatsD_ e esses projetos forma herdados no _OpenTelemetry_. Essa foi a peça que faltava pra encaixar o ecossitema de observabilidade que já funcionava muito bem ao _OpenTelemetry_, por meio do seu componente de _Collector_, foi a peça que encaixou esses formatos abertos com o _New Relic_.

Lembra que o _Hyperf_ é todo focado em microsserviços, inclusive na parte de Observabilidade? Então, ele mesmo já provê dois componentes chamados hyperf/trace e hyperf/metric que servem justamente para fazer a instrumentação das aplicações em _Hyperf_ e exportá-las para formatos abertos.

#### Instrumentação com AOP

Um ponto bem legal sobre a instrumentação para evitar aquele problema de ter ela misturada com regras de negócio e código que faz outras coisas, é que o _Hyperf_ utiliza uma técnica chama AOP, de _Aspect Oriented Programming_, ela é uma forma de implementar _Monkey Patch_ (lembra dele?), ou seja, a gente consegue adicionar comportamento (no caso de instrumentação) em classes, métodos e funções, sem de fato alterar o código delas.

Só que dessa vez, esse _monkey patch_ feito com AOP fornecido pelo _Hyperf_, é feito com o próprio PHP, não temos o problema de conflito com o _monkey patch_ feito pela _Swoole_ para deixar os componentes do PHP não-bloqueantes.

Recomendo bastante darem uma lida na técnica: [https://en.wikipedia.org/wiki/Aspect-oriented\_programming](https://en.wikipedia.org/wiki/Aspect-oriented_programming)

### Conclusão

![](media/image-02.png)

#### Aplicação feita com Hyperf

É instrumentada e exporta os dados em formatos abertos, como _Jaeger_ e _StatsD_.

#### OpenTelemetry Collector

Por ser a junção do _OpenTracing_ com o _OpenCensus_, herda a possibilidade de receber formatos abertos (como _Jaeger_ e _Statsd_) e tem suporte da própria _New Relic_ para exportar os dados para sua plataforma.

#### New Relic

Super parceira do projeto, apoia a iniciativa e vem dando cada vez mais suporte para receber os dados que foram gerados pelos componentes do _OpenTelemetry_.
