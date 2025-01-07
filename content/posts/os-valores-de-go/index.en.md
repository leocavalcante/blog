---
title: Go's Values
description: Since its release in 2009, the Go programming language has won over developers around the world, especially in distributed systems, cloud computing, and ...
date: "2025-01-07T08:00:22-03:00"
updated: ""
draft: false
tags:
    - go
url: /en/os-valores-de-go/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Since its release in 2009, the Go programming language has won over developers around the world, especially in distributed systems, cloud computing, and DevOps. But what exactly makes Go such an attractive language? Beyond its technical characteristics, it is the underlying philosophy that truly defines what Go represents. [This thread](https://www.reddit.com/r/golang/comments/1hs1yx3/what_are_gos_values/) on Reddit brought together the core values that shape the language and how they impact the developer experience.

## Simplicity as a foundation

One of Go's most striking characteristics is its simplicity. The language's syntax is straightforward and easy to learn, even for developers coming from other languages. For example, while other languages allow elaborate ways to define functions or structures, Go chooses a clear and concise pattern:

```go
func add(a int, b int) int {
    return a + b
}
```

This simplicity is not just a matter of aesthetic design. It has a direct impact on productivity, making it easier for new team members to join existing projects and reducing the risk of complex errors in the code.

## Orthogonality and consistency

Go follows the principle of orthogonality, in which each language feature is designed to work well in combination with others without unnecessary overlap. For example, Go does not have classical class inheritance as in Java or C++. Instead, it uses implicit interfaces, which promote composition rather than inheritance:

```go
type Shape interface {
    Area() float64
}

type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

// Rectangle implementa Shape sem declaração explícita.
```

This eliminates ambiguities and makes the code more predictable and readable.

## Intentional minimalism

Go deliberately avoids including features that could increase unnecessary complexity. For example, while many languages include support for function overloading or multiple inheritance, Go chooses to avoid those features, prioritizing simplicity and predictability.

Another clear example is error handling. Instead of using exceptions, Go adopts an explicit error return model:

```go
file, err := os.Open("example.txt")
if err != nil {
    log.Fatal(err)
}
```

Although this may seem verbose, it ensures that the developer handles errors consciously and clearly, reducing silent bugs.

## Concurrency

Concurrency is a necessity for many modern applications, and Go was designed from the start to handle it efficiently. The model based on goroutines and channels simplifies writing concurrent code:

```go
func worker(id int, jobs <-chan int, results chan<- int) {
    for j := range jobs {
        results <- j * 2
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan int, 100)

    for w := 1; w <= 3; w++ {
        go worker(w, jobs, results)
    }

    for j := 1; j <= 10; j++ {
        jobs <- j
    }
    close(jobs)

    for a := 1; a <= 10; a++ {
        fmt.Println(<-results)
    }
}
```

The model allows developers to handle concurrent tasks intuitively and efficiently, without having to resort to complex libraries or external abstractions.

## Performance and efficiency

As a compiled language, Go offers performance similar to languages such as C and C++, while providing memory safety and a garbage collector to reduce the risk of common errors.

For example, Go is widely used in Kubernetes, which manages thousands of containers in real time with high efficiency. Its ability to handle intensive *workloads* reliably is a testament to its performance.

## Integrated tools and a rich ecosystem

Go comes with integrated tools that make developers' lives easier. The `go fmt` command, for example, ensures that all code is formatted consistently:

```bash
go fmt ./...
```

Other tools, such as `go test` for testing and `go mod` for dependency management, are part of the standard ecosystem and eliminate the need to configure external tools.

## Stability and backward compatibility

Since the release of Go 1.0, the language development team has committed to backward compatibility. This means that code written in earlier versions of Go continues to work in newer versions. This commitment significantly reduces long-term maintenance costs.

## Opinionated design

Go is an opinionated language, which means it favors strong conventions and avoids ambiguity. For example, the use of `gofmt` is not optional. This promotes a uniform style across the entire codebase, regardless of who is writing it.

In addition, the language takes an uncompromising approach to including features. This can frustrate some developers, but it also avoids the excessive complexity that can arise from having multiple ways to do the same thing.

## Productivity

All of Go's values converge toward one main goal: maximizing developer productivity. From its fast compilation to its simplicity and integrated tooling, everything in Go was designed to help developers create robust and scalable applications quickly.

Go is much more than just a programming language; it is a manifestation of values that put simplicity, efficiency, and collaboration first. Its clear and coherent design philosophy not only makes it easier to create high-quality software, but also promotes a culture of readable and maintainable code. These are the reasons why Go continues to grow in popularity and influence the design of future languages.
