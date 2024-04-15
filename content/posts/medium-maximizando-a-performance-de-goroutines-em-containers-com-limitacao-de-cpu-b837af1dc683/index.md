---
title: Maximizando a Performance de Goroutines em Containers com Limitação de CPU
description: Na busca contínua por linguagens de programação eficientes e concorrentes, a linguagem Go tem se destacado por sua simplicidade, desempenho e recursos poderosos. Um dos recursos...
date: "2024-04-15T10:11:04-03:00"
updated: "2024-04-17T14:44:14-03:00"
draft: false
tags:
    - concurrency
    - go
    - golang
    - kubernetes
    - threads
url: /archive/medium/maximizando-a-performance-de-goroutines-em-containers-com-limitacao-de-cpu-b837af1dc683/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Na busca contínua por linguagens de programação eficientes e concorrentes, a linguagem Go tem se destacado por sua simplicidade, desempenho e recursos poderosos. Um dos recursos mais distintivos de Go é o conceito de **Goroutines**, que permite a execução concorrente de tarefas de forma eficiente.

Neste artigo, vamos mergulhar no funcionamento das Goroutines em Go, entender como elas se relacionam com threads, CPUs e processos em sistemas operacionais, e discutir a melhor prática para configurar a quantidade de processos em um ambiente Kubernetes.

![](cover.jpg)

### Goroutines: o poder da concorrência

As Goroutines são leves, gerenciadas pelo runtime de Go, e permitem que os desenvolvedores escrevam código concorrente de maneira simples e eficaz. Enquanto outras linguagens de programação exigem o uso explícito de _threads_ para alcançar a concorrência, em Go, as Goroutines são criadas facilmente adicionando a palavra-chave go antes de uma função ou método. Por exemplo:

```
func main() {
    go minhaFuncaoConcorrente()
    // Código principal continua aqui
}

func minhaFuncaoConcorrente() {
    // Lógica da Goroutine
}
```

Quando uma Goroutine é criada, ela é executada de forma independente de outras Goroutines, permitindo que várias tarefas sejam realizadas simultaneamente sem a complexidade associada ao uso direto de _threads_.

### Threads, CPUs e processos em sistemas operacionais

Para entender completamente o funcionamento das Goroutines, é importante ter uma compreensão básica de como _threads_, CPUs e processos são gerenciados pelos sistemas operacionais.

- **Threads**: uma thread é uma unidade básica de execução dentro de um processo. Elas compartilham o mesmo espaço de memória e recursos do processo pai, permitindo a execução concorrente de várias partes do código. No entanto, as _threads_ também têm seu próprio contexto de execução, incluindo o contador de programa, registradores e pilha.
- **CPUs**: as CPUs são responsáveis pela execução das instruções de um programa. Múltiplas CPUs em um sistema permitem a execução paralela de várias _threads_, aumentando assim a capacidade de processamento.
- **Processos**: um processo é uma instância de um programa em execução. Ele contém o código do programa, dados, pilha e outros recursos necessários para a execução. Cada processo é isolado de outros processos, o que significa que eles não compartilham memória ou outros recursos diretamente.

### Goroutines vs. Threads

Embora as Goroutines e as _threads_ tenham objetivos semelhantes de permitir a execução concorrente, há diferenças significativas em como elas são implementadas e gerenciadas.

- **Leveza**: as Goroutines são extremamente leves em comparação com as _threads_. Enquanto uma _thread_ pode consumir uma quantidade significativa de memória e recursos do sistema, as Goroutines são gerenciadas de forma mais eficiente pelo runtime de Go.
- **Escalabilidade**: devido à sua leveza, é possível criar um grande número de Goroutines em uma única aplicação Go sem sobrecarregar o sistema. Por outro lado, criar um grande número de _threads_ pode levar a problemas de escalabilidade devido ao consumo excessivo de recursos.
- **Comunicação**: em Go, a comunicação entre Goroutines é facilitada pelo uso de canais, que permitem a troca segura de dados entre Goroutines sem o risco de condições de corrida ( _race conditions_). Em contraste, a comunicação entre _threads_ em outras linguagens muitas vezes requer o uso de primitivas de sincronização, como _locks_, _mutexes_ e semáforos.

### Multiplexing entre Goroutines e Threads

A Go utiliza um modelo de _multiplexing_ inteligente para gerenciar as Goroutines de forma eficiente em relação às _threads_ do sistema operacional. Esse modelo é conhecido como M:N, onde M Goroutines são mapeadas para N threads do sistema operacional. A Go Runtime mantém um conjunto de _threads_ gerenciadas internamente, que são responsáveis por executar as Goroutines.

Quando uma Goroutine é criada, ela é colocada em uma fila de Goroutines prontas para execução. O agendador de Goroutines de Go, seleciona uma Goroutine da fila e a agenda para execução em uma das _threads_ disponíveis. Se uma Goroutine bloqueia devido a operações de I/O ou sincronização, o agendador de Goroutines escolhe outra Goroutine pronta para execução e a executa na mesma _thread_. Isso evita o desperdício de recursos devido à espera passiva de Goroutines bloqueadas.

### Quantas threads para quantas Goroutines?

O GOMAXPROCS é uma variável de ambiente e uma configuração de tempo de execução de Go que determina o número máximo de CPUs que podem ser utilizadas simultaneamente para executar as Goroutines de um programa Go. Esta configuração controla a quantidade de paralelismo que um programa Go pode alcançar.

### Funcionamento do GOMAXPROCS

Por padrão, o Go define o valor de GOMAXPROCS como o número de núcleos de CPU disponíveis no sistema, que pode ser obtido usando a função runtime.NumCPU(). Isso significa que, por padrão, a Go aproveita todos os núcleos de CPU disponíveis para executar Goroutines simultaneamente. No entanto, você pode alterar manualmente o valor de GOMAXPROCS para ajustar o nível de paralelismo de acordo com as necessidades do seu programa.

### Maximizando os recursos computacionais com GOMAXPROCS

A configuração GOMAXPROCS pode ser usada para maximizar os recursos computacionais de várias maneiras:

1. **Aproveitar todos os núcleos de CPU disponíveis**: ao definir GOMAXPROCS como o número total de núcleos de CPU no sistema, você garante que todas as CPUs estejam sendo utilizadas eficientemente para executar Goroutines em paralelo.
2. **Controlar o consumo de recursos**: em certos casos, pode ser vantajoso limitar o número de CPUs que o seu programa utiliza, especialmente em sistemas com várias instâncias de programas Go em execução simultânea. Isso pode ajudar a evitar uma competição excessiva por recursos de CPU e a garantir uma distribuição equitativa de recursos entre os programas em execução.
3. **Otimização para casos específicos**: dependendo do tipo de aplicação que você está desenvolvendo, pode ser benéfico ajustar manualmente o valor de GOMAXPROCS para otimizar o desempenho. Por exemplo, em certos cenários de I/O intensivo, pode ser útil limitar o número de CPUs utilizadas para evitar sobrecarregar o sistema com Goroutines de computação intensiva.

### Exemplo prático

```
package main

import (
    "fmt"
    "runtime"
)
func main() {
    // Obtém o número de CPUs disponíveis no sistema
    numCPU := runtime.NumCPU()
    fmt.Printf("Número de núcleos de CPU disponíveis: %d\\\\n", numCPU)
    // Define GOMAXPROCS como o número total de CPUs disponíveis
    runtime.GOMAXPROCS(numCPU)
    // Seu código aqui...
}
```

Neste exemplo, runtime.NumCPU() é usado para obter o número de núcleos de CPU disponíveis no sistema. Em seguida, runtime.GOMAXPROCS() é chamado para definir GOMAXPROCS como o número total de CPUs disponíveis. Isso garante que o programa utilize eficientemente todos os recursos computacionais disponíveis para executar Goroutines em paralelo.

### Otimizando GOMAXPROCS em ambientes Kubernetes

Ao lidar com ambientes de containers, como Kubernetes, é fundamental considerar não apenas a quantidade de CPUs disponíveis no sistema, mas também as restrições e limitações impostas aos containers. Embora o uso da função **runtime.NumCPU()** possa parecer uma abordagem simples para determinar a quantidade de CPUs disponíveis, ela pode não refletir com precisão o contexto em que a aplicação está sendo executada.

Em ambientes de container, os limites de CPU podem ser definidos para evitar que uma única instância da aplicação consuma todos os recursos disponíveis no cluster. Quando um container excede seu limite de CPU, ele pode ser “estrangulado” (o famoso _throttling_) pelo sistema, resultando em uma diminuição significativa no desempenho.

### Limitações de CPU em containers

O uso de **runtime.NumCPU()** simplesmente retorna o número de CPUs disponíveis no sistema hospedeiro, ou seja, do nó, sem considerar os limites de CPU definidos para o container. Isso significa que, mesmo que o container tenha uma limitação de CPU mais baixa, **runtime.NumCPU()** ainda retornará o número total de CPUs disponíveis no nó, o que pode levar a uma configuração inadequada de **GOMAXPROCS**.

Em um cenário onde um container Kubernetes tem uma limitação de CPU mais baixa do que o número total de CPUs disponíveis no nó, configurar **GOMAXPROCS** com base em **runtime.NumCPU()** pode resultar em uma utilização excessiva de recursos e possivelmente levar ao throttling do container.

### Abordagem recomendada

Em vez de depender exclusivamente de **runtime.NumCPU()**, é recomendável usar uma abordagem mais abrangente que leve em consideração não apenas o número de CPUs disponíveis no nó, mas também as restrições e limitações impostas ao container pelo ambiente Kubernetes.

O projeto **automaxprocs** da Uber oferece uma solução para esse problema, automatizando a determinação ideal de **GOMAXPROCS** com base na disponibilidade de recursos e nas limitações do container. Ao adotar essa abordagem, os desenvolvedores podem garantir uma utilização eficiente dos recursos do sistema e evitar possíveis problemas de desempenho causados pela configuração inadequada.

[https://github.com/uber-go/automaxprocs](https://github.com/uber-go/automaxprocs)

### Conclusão

As Goroutines em Go oferecem uma maneira poderosa e eficiente de lidar com a concorrência em aplicativos. Ao entender como as Goroutines se relacionam com threads, CPUs e processos em sistemas operacionais, os desenvolvedores podem escrever código concorrente de maneira mais eficaz e otimizar a utilização de recursos em ambientes como Kubernetes. Com as melhores práticas adequadas, é possível criar aplicativos Go altamente escaláveis e eficientes em recursos.
