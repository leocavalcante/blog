---
title: What's New in Go 1.24
description: Version 1.24 of the Go language was released in February 2025, bringing a series of improvements and new features that promise to increase developer productivity...
date: "2025-02-12T15:57:00-03:00"
updated: ""
draft: false
tags:
    - go
    - releases
    - tooling
    - performance
    - webassembly
url: /en/novidades-do-go-124/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Version 1.24 of the Go language was released in February 2025, bringing a series of improvements and new features that promise to increase developer productivity and optimize application performance. In this article, we will highlight some of the main new features, such as the new `tool` directive, support for generics in type aliases, the `Loop` function for benchmark tests, performance improvements, enhanced WebAssembly support, and the new `AddCleanup` function.

## 1\. New `tool` Directive for Tool Dependency Management

One of the most interesting new features in Go 1.24 is the introduction of the `tool` directive in `go.mod`, which allows tool dependencies to be managed more efficiently. Previously, it was necessary to add tools as blank imports in a `tools.go` file, which could be somewhat inconvenient. Now, with the new `tool` directive, you can add tools directly to `go.mod` using the `go get -tool` command.

For example, to add a tool called `golangci-lint`, you can run:

```bash
go get -tool github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.4
```

This will add a `tool` directive to your `go.mod`, allowing you to run the tool with the `go tool golangci-lint` command. In addition, all tools declared in the module can be updated at once with `go get tool`.

This change simplifies tool management and makes the process more integrated with the Go workflow.

## 2\. Support for Generics in Type Aliases

Go 1.24 brings a significant improvement to generics support by allowing **type aliases** to be parameterized, just like defined types. This means you can now create aliases for generic types, increasing flexibility and code reuse.

For example, you can define an alias for a generic type as follows:

```go
type MyList[T any] = []T
```

This allows you to use `MyList` as an alias for a generic list, simplifying the syntax and improving code readability.

## 3\. New `Loop` Function in Benchmark Tests

Another important addition in Go 1.24 is the new `Loop` function for benchmark tests. Previously, benchmarks were written using a `for` loop with `b.N`, which could be error-prone and less efficient. Now you can use the `Loop` function to simplify benchmark iteration execution:

```go
for b.Loop() {
    // Código do benchmark
}
```

This approach is safer and more efficient because it ensures that the benchmark code is executed exactly once per iteration, avoiding common issues related to the use of `b.N`. In addition, the `Loop` function keeps the function parameters and results alive, which prevents the compiler from completely optimizing away the loop body.

## 4\. Performance Improvements

Go 1.24 brings several performance improvements, especially in the runtime. Among the main changes are:

* **New map implementation based on Swiss Tables**: This new implementation reduces CPU overhead by 2-3% in representative benchmarks.

* **More efficient memory allocation for small objects**: This results in reduced memory consumption and faster execution for applications that handle many small objects.

* **New internal mutex implementation**: The new mutex is more efficient and less error-prone, improving concurrency in applications that depend on synchronization.


These improvements make Go 1.24 an even more attractive choice for high-performance applications.

## 5\. Enhanced WebAssembly Support

WebAssembly (Wasm) support has been significantly improved in Go 1.24. You can now export Go functions to the WebAssembly host using the new `go:wasmexport` directive. In addition, Go 1.24 supports building Go programs as libraries or reactors in the WebAssembly System Interface (WASI) using the `-buildmode=c-shared` flag.

This improvement makes it easier to integrate Go code into WebAssembly environments, allowing developers to create more efficient and interoperable web applications.

## 6\. New `AddCleanup` Function for Object Finalization

The `runtime.AddCleanup` function was introduced in Go 1.24 as a more flexible and efficient alternative to `runtime.SetFinalizer`. With `AddCleanup`, you can attach cleanup functions to objects that will run when the object is no longer reachable.

The main advantage of `AddCleanup` is that it allows multiple cleanup functions for a single object, and those functions can be attached to interior pointers. In addition, `AddCleanup` does not cause memory leaks when objects form cycles, and it does not delay memory release.

Usage example:

```go
obj := &MyObject{}
runtime.AddCleanup(obj, func() {
    fmt.Println("Cleanup executed")
})
```

This new function is a valuable addition for resource management and memory cleanup in Go applications.

## In short

Go 1.24 brings a series of improvements that reinforce the language as one of the best choices for modern software development. From simplified tool management with the `tool` directive, through support for generics in type aliases, to performance improvements and WebAssembly support, this version offers powerful tools for developers.

The new `Loop` function for benchmarks and the `AddCleanup` function for object finalization are examples of how Go continues to evolve to meet developers' needs, making the language safer, more efficient, and easier to use.

If you have not tried Go 1.24 yet, now is the time to update your environment and explore these new features. The Go community is more active than ever, and with these improvements, the language is ready to face the challenges of modern software development.

[https://go.dev/blog/go1.24](https://go.dev/blog/go1.24)
[https://go.dev/doc/go1.24](https://go.dev/doc/go1.24)
