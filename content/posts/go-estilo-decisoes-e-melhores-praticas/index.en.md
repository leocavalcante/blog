---
title: 'Go: Style, Decisions, and Best Practices'
description: Google's style, decisions, and best practices guide for the Go language is a set of recommendations intended to promote clarity, simplicity, and efficiency in software developm...
date: "2025-01-20T08:00:23-03:00"
updated: ""
draft: false
tags:
    - best-practices
    - go
    - google
    - styleguide
url: /en/go-estilo-decisoes-e-melhores-praticas/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Google's style, decisions, and best practices guide for the Go language is a set of recommendations intended to promote clarity, simplicity, and efficiency in code development.

These guidelines help developers write readable and maintainable code, which is essential for long-term projects. In this article, we explore the main points covered in these documents, emphasizing the importance of consistency, maintenance, and collaboration within development teams.

## 1\. Code Style

Maintaining a consistent code style is essential for team collaboration and project maintenance. It also makes code reviews and onboarding new team members easier.

### 1.1 Formatting

Use `gofmt` to ensure standardized formatting. Using this tool removes ambiguity around spacing, indentation, and code organization. In addition, it integrates easily with IDEs and CI/CD pipelines.

**Additional best practices:**

* Avoid lines longer than 80 characters to improve readability.

* Use spaces instead of tabs to ensure compatibility across different editors.


**Example:**

```go
// Formatação correta
func Add(a int, b int) int {
    return a + b
}

// Formatação incorreta
func Add(a int, b int) int {
return a + b // Errado: indentacão incorreta
}
```

### 1.2 Naming Conventions

Names for variables, functions, and packages should be clear and descriptive, reflecting their responsibilities. This improves maintainability and reduces the need for extensive comments.

**Main rules:**

* **camelCase:** Use for variables, functions, and internal arguments.

* **PascalCase:** Use for exported functions, structures, and constants.

* **snake\_case:** Avoid this pattern in Go code.

* Packages should use short lowercase names, without underscores.


**Example:**

```go
// Correto
func CalculateSum(a int, b int) int {
    total := a + b
    return total
}

// Errado
func calculatesum(a int, b int) int {
    total := a + b
    return total
}
```

**Package names:**

```go
// Correto
package mathutils

// Errado
package math_utils
```

### 1.3 Comments

Add explanatory comments that describe the "why" rather than the "how". Excessive or redundant comments should be avoided. For exported functions, follow Go's standard format, where the comment begins with the function name.

**Best practices:**

* Use docstrings for packages and important functions.

* Comments should be updated whenever code behavior changes.


**Example:**

```go
// CalculateSum soma dois inteiros e retorna o resultado.
func CalculateSum(a int, b int) int {
    return a + b
}

// Comentário redundante e desnecessário
// A função retorna a soma de dois inteiros
func Sum(a, b int) int {
    return a + b
}
```

---

## 2\. Design Decisions

Clear decisions about project organization and use of language features help avoid confusion, bugs, and rework. A well-thought-out design also makes it easier to expand the project in the future.

### 2.1 Project Structure

Code organization should be modular, intuitive, and reflect the system's main goals. Adopt a directory structure that favors separation of concerns.

**Guidelines:**

* Avoid generic packages such as `utils` whenever possible. Prefer specific names.

* Keep `main.go` clean and delegate logic to other packages.

* Use patterns such as `internal/` for code that should not be accessed outside the repository.


**Suggested structure:**

```plaintext
project/
    cmd/
        app/
            main.go
    mathutils/
        math.go
    internal/
        db/
            connection.go
```

### 2.2 Interfaces

Interfaces are most effective when they are small and represent a single responsibility. This allows greater implementation flexibility and makes testing easier.

**Principles:**

* Avoid adding methods to an interface before they are needed.

* Use composition to create more complex interfaces.


**Example:**

```go
// Correto
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Composição de interfaces
type ReadWriter interface {
    Reader
    Write(p []byte) (n int, err error)
}

// Errado: Interface genérica e inflexível
type Service interface {
    Start()
    Stop()
    Restart()
}
```

### 2.3 Dependency Control

Dependency management is crucial for maintaining project security and stability. Use `go mod` to manage dependencies efficiently.

**Best practices:**

* Update dependencies regularly and test carefully before merging.

* Use tools such as `dependabot` to monitor updates.


**Example:**

```plaintext
module example.com/project

go 1.20

require (
    github.com/pkg/errors v0.9.1
)
```

---

## 3\. Best Practices

### 3.1 Error Handling

Error management in Go is designed to be simple and explicit. Always handle errors immediately or propagate them with additional context.

**Tips:**

* Use `errors.Is` and `errors.As` to check and unwrap errors.

* Standardize error messages to make debugging easier.


**Example:**

```go
if err := doSomething(); err != nil {
    if errors.Is(err, ErrSpecific) {
        return fmt.Errorf("erro especifico: %w", err)
    }
    return fmt.Errorf("erro genérico: %w", err)
}
```

### 3.2 Concurrency

Go's built-in support for concurrency is one of its greatest strengths. However, common mistakes such as Goroutine leaks or unsynchronized concurrent accesses should be avoided.

**Useful tools:**

* `sync.WaitGroup` to wait for multiple Goroutines.

* `sync.Mutex` to protect critical sections.

* `context.Context` to cancel Goroutines.


**Example with Context:**

```go
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

ch := make(chan int)

go func() {
    defer close(ch)
    for i := 0; i < 5; i++ {
        select {
        case <-ctx.Done():
            return
        case ch <- i:
        }
    }
}()

for val := range ch {
    fmt.Println(val)
}
```

### 3.3 Logging

Structured logs help with monitoring and diagnosing production issues. Prefer libraries such as `log/slog` for richer and more configurable logs.

**Example:**

```go
package main

import (
	"log/slog"
)

func main() {
	// Criando um logger padrão
	logger := slog.Default()

	// Registrando uma mensagem de informação com campos
	logger.Info("iniciando operação",
		slog.Int("valor", 42),
		slog.String("status", "inicializado"))
}
```

### 3.4 Testing

Adopt TDD (Test-Driven Development) whenever possible. Use subtests to split complex tests into smaller parts, and mock modules to simulate external dependencies.

**Example with mocks:**

```go
type MockService struct {}

func (m *MockService) Process(data string) error {
    if data == "error" {
        return errors.New("mock error")
    }
    return nil
}

func TestService(t *testing.T) {
    service := &MockService{}
    err := service.Process("error")
    if err == nil {
        t.Fatalf("esperava erro, mas obteve nil")
    }
}
```

---

In short, Google's recommended style, decisions, and best practices guides for Go are fundamental to ensuring that code is clear, concise, and easy to maintain. Following these guidelines not only improves code quality, but also makes collaboration easier on development teams. These practices promote consistency and readability, essential elements for successful long-term projects. For more information, see the full resources on the [official site](https://google.github.io/styleguide/go/).
