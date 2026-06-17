---
title: Maximizing Goroutine Performance in CPU-Limited Containers
description: In the ongoing search for efficient and concurrent programming languages, the Go language has stood out for its simplicity, performance, and powerful features. One of the features...
date: "2024-04-15T10:11:04-03:00"
updated: "2024-04-17T14:44:14-03:00"
draft: false
tags:
    - go
    - concurrency
    - kubernetes
    - performance
    - containers
url: /en/archive/medium/maximizando-a-performance-de-goroutines-em-containers-com-limitacao-de-cpu-b837af1dc683/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

In the ongoing search for efficient and concurrent programming languages, the Go language has stood out for its simplicity, performance, and powerful features. One of Go's most distinctive features is the concept of **Goroutines**, which enables efficient concurrent execution of tasks.

In this article, we will dive into how Goroutines work in Go, understand how they relate to threads, CPUs, and processes in operating systems, and discuss the best practice for configuring the number of processes in a Kubernetes environment.

![](cover.jpg)

### Goroutines: the power of concurrency

Goroutines are lightweight, managed by the Go runtime, and allow developers to write concurrent code in a simple and effective way. While other programming languages require the explicit use of _threads_ to achieve concurrency, in Go, Goroutines are created easily by adding the go keyword before a function or method. For example:

```
func main() {
    go minhaFuncaoConcorrente()
    // Código principal continua aqui
}

func minhaFuncaoConcorrente() {
    // Lógica da Goroutine
}
```

When a Goroutine is created, it runs independently of other Goroutines, allowing multiple tasks to be performed simultaneously without the complexity associated with direct use of _threads_.

### Threads, CPUs, and processes in operating systems

To fully understand how Goroutines work, it is important to have a basic understanding of how _threads_, CPUs, and processes are managed by operating systems.

- **Threads**: a thread is a basic unit of execution within a process. Threads share the same memory space and resources of the parent process, allowing concurrent execution of multiple parts of the code. However, _threads_ also have their own execution context, including the program counter, registers, and stack.
- **CPUs**: CPUs are responsible for executing a program's instructions. Multiple CPUs in a system allow parallel execution of several _threads_, increasing processing capacity.
- **Processes**: a process is an instance of a running program. It contains the program code, data, stack, and other resources required for execution. Each process is isolated from other processes, which means they do not share memory or other resources directly.

### Goroutines vs. Threads

Although Goroutines and _threads_ have similar goals of enabling concurrent execution, there are significant differences in how they are implemented and managed.

- **Lightweight nature**: Goroutines are extremely lightweight compared with _threads_. While a _thread_ may consume a significant amount of memory and system resources, Goroutines are managed more efficiently by the Go runtime.
- **Scalability**: because they are lightweight, it is possible to create a large number of Goroutines in a single Go application without overloading the system. On the other hand, creating a large number of _threads_ can lead to scalability issues due to excessive resource consumption.
- **Communication**: in Go, communication between Goroutines is facilitated through channels, which allow safe data exchange between Goroutines without the risk of race conditions ( _race conditions_). In contrast, communication between _threads_ in other languages often requires synchronization primitives such as _locks_, _mutexes_, and semaphores.

### Multiplexing between Goroutines and Threads

Go uses a smart _multiplexing_ model to manage Goroutines efficiently in relation to operating system _threads_. This model is known as M:N, where M Goroutines are mapped to N operating system threads. The Go Runtime maintains a set of internally managed _threads_ that are responsible for executing Goroutines.

When a Goroutine is created, it is placed in a queue of Goroutines ready to run. Go's Goroutine scheduler selects a Goroutine from the queue and schedules it for execution on one of the available _threads_. If a Goroutine blocks due to I/O or synchronization operations, the Goroutine scheduler chooses another ready-to-run Goroutine and runs it on the same _thread_. This avoids wasting resources due to passive waiting by blocked Goroutines.

### How many threads for how many Goroutines?

GOMAXPROCS is an environment variable and a Go runtime setting that determines the maximum number of CPUs that can be used simultaneously to execute the Goroutines of a Go program. This setting controls the amount of parallelism a Go program can achieve.

### How GOMAXPROCS works

By default, Go sets the value of GOMAXPROCS to the number of CPU cores available in the system, which can be obtained using the runtime.NumCPU() function. This means that, by default, Go takes advantage of all available CPU cores to execute Goroutines simultaneously. However, you can manually change the value of GOMAXPROCS to adjust the level of parallelism according to your program's needs.

### Maximizing computational resources with GOMAXPROCS

The GOMAXPROCS setting can be used to maximize computational resources in several ways:

1. **Use all available CPU cores**: by setting GOMAXPROCS to the total number of CPU cores in the system, you ensure that all CPUs are being used efficiently to execute Goroutines in parallel.
2. **Control resource consumption**: in certain cases, it may be advantageous to limit the number of CPUs your program uses, especially on systems with multiple Go program instances running simultaneously. This can help avoid excessive competition for CPU resources and ensure an equitable distribution of resources among running programs.
3. **Optimization for specific cases**: depending on the type of application you are developing, it may be beneficial to manually adjust the value of GOMAXPROCS to optimize performance. For example, in certain I/O-intensive scenarios, it may be useful to limit the number of CPUs used to avoid overloading the system with compute-intensive Goroutines.

### Practical example

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

In this example, runtime.NumCPU() is used to get the number of CPU cores available in the system. Then runtime.GOMAXPROCS() is called to set GOMAXPROCS to the total number of available CPUs. This ensures that the program efficiently uses all available computational resources to execute Goroutines in parallel.

### Optimizing GOMAXPROCS in Kubernetes environments

When dealing with container environments such as Kubernetes, it is essential to consider not only the number of CPUs available in the system, but also the restrictions and limits imposed on containers. Although using the **runtime.NumCPU()** function may seem like a simple approach to determining the number of available CPUs, it may not accurately reflect the context in which the application is running.

In container environments, CPU limits can be defined to prevent a single application instance from consuming all available resources in the cluster. When a container exceeds its CPU limit, it may be "throttled" (the well-known _throttling_) by the system, resulting in a significant performance decrease.

### CPU limits in containers

Using **runtime.NumCPU()** simply returns the number of CPUs available on the host system, that is, on the node, without considering the CPU limits defined for the container. This means that even if the container has a lower CPU limit, **runtime.NumCPU()** will still return the total number of CPUs available on the node, which may lead to an inadequate **GOMAXPROCS** configuration.

In a scenario where a Kubernetes container has a lower CPU limit than the total number of CPUs available on the node, configuring **GOMAXPROCS** based on **runtime.NumCPU()** may result in excessive resource usage and possibly lead to container throttling.

### Recommended approach

Instead of relying exclusively on **runtime.NumCPU()**, it is recommended to use a more comprehensive approach that takes into account not only the number of CPUs available on the node, but also the restrictions and limits imposed on the container by the Kubernetes environment.

Uber's **automaxprocs** project offers a solution to this problem by automating the ideal determination of **GOMAXPROCS** based on resource availability and container limits. By adopting this approach, developers can ensure efficient use of system resources and avoid potential performance issues caused by improper configuration.

[https://github.com/uber-go/automaxprocs](https://github.com/uber-go/automaxprocs)

### Conclusion

Goroutines in Go offer a powerful and efficient way to handle concurrency in applications. By understanding how Goroutines relate to threads, CPUs, and processes in operating systems, developers can write concurrent code more effectively and optimize resource usage in environments such as Kubernetes. With the right best practices, it is possible to create highly scalable and resource-efficient Go applications.
