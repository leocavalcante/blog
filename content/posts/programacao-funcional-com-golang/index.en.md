---
title: Functional Programming with Golang
description: Functional programming (FP) has gained popularity in recent years due to its ability to create more expressive, modular code with fewer side effects. Go...
date: "2025-01-28T17:23:39-03:00"
updated: ""
draft: false
tags:
    - go
    - functional-programming
    - programming
    - libraries
    - development
url: /en/programacao-funcional-com-golang/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Functional programming (FP) has gained popularity in recent years due to its ability to create more expressive, modular code with fewer side effects. Although Go is a language designed primarily for the imperative paradigm, it has several characteristics that make it possible to adopt functional programming concepts. This article explores how to apply functional programming principles in Go development.

---

## What is Functional Programming?

Functional programming is a software development paradigm that emphasizes the use of pure functions, immutability, and function composition. Unlike imperative paradigms, where the focus is on state mutation and the use of sequential commands, the functional paradigm encourages declarative constructs and minimizing side effects.

The main concepts of functional programming include:

1. **Pure Functions**: A pure function always returns the same result for the same arguments and has no side effects.
2. **Immutability**: Data is not modified after it is created.
3. **Function Composition**: Combining smaller functions to create more complex functionality.
4. **Higher-Order Functions**: Functions that accept other functions as arguments or return functions.
5. **Lazy Evaluation**: Evaluation of expressions only when necessary (not directly supported by Go).

---

## Functional Programming in Go

Although Go is not a purely functional language, it supports many of the functional paradigm's principles. Let's explore how this can be done in practice.

### Higher-Order Functions

Go allows functions to be treated as first-class citizens. This means we can pass functions as arguments, return them from other functions, or store them in variables.

```go
package main

import (
	"fmt"
)

// Função que aceita outra função como argumento
def applyOperation(x int, y int, operation func(int, int) int) int {
	return operation(x, y)
}

func main() {
	sum := func(a, b int) int {
		return a + b
	}

	product := func(a, b int) int {
		return a * b
	}

	fmt.Println("Soma:", applyOperation(3, 4, sum))
	fmt.Println("Produto:", applyOperation(3, 4, product))
}
```

In this example, the `applyOperation` function accepts a function as a parameter and uses it to apply different operations to the provided values.

### Pure Functions

Pure functions are functions that do not depend on or alter external state. This makes code easier to test and more predictable.

```go
package main

import "fmt"

// Função pura: sempre retorna o mesmo resultado para os mesmos inputs
func add(a, b int) int {
	return a + b
}

func main() {
	fmt.Println(add(2, 3))
	fmt.Println(add(2, 3)) // Sempre o mesmo resultado
}
```

### Immutability

Although Go does not have native support for immutability like some functional languages (for example, Haskell), it is possible to adopt good practices to avoid unnecessary state changes.

```go
package main

import "fmt"

func immutableIncrement(numbers []int) []int {
	newNumbers := make([]int, len(numbers))
	for i, v := range numbers {
		newNumbers[i] = v + 1
	}
	return newNumbers
}

func main() {
	nums := []int{1, 2, 3}
	newNums := immutableIncrement(nums)

	fmt.Println("Original:", nums)
	fmt.Println("Novo:", newNums)
}
```

In this example, instead of modifying the original slice, we create a new copy with the desired changes.

### Function Composition

Although Go does not have native support for function composition like other languages (for example, `pipe` in Elixir), we can implement our own composition function.

```go
package main

import "fmt"

func compose(f, g func(int) int) func(int) int {
	return func(x int) int {
		return f(g(x))
	}
}

func main() {
	double := func(x int) int { return x * 2 }
	square := func(x int) int { return x * x }

	composed := compose(square, double)
	fmt.Println(composed(3)) // Resultado: 36 (square(double(3)))
}
```

### Using Closures

Closures are functions that "remember" the environment in which they were created. In Go, closures are useful for encapsulating logic.

```go
package main

import "fmt"

func makeMultiplier(factor int) func(int) int {
	return func(x int) int {
		return x * factor
	}
}

func main() {
	double := makeMultiplier(2)
	triple := makeMultiplier(3)

	fmt.Println(double(5)) // 10
	fmt.Println(triple(5)) // 15
}
```

### Working with Map, Filter, and Reduce

Although Go does not have native functions such as `map`, `filter`, and `reduce` available in languages like Python or JavaScript, we can implement them.

#### Map

```go
func mapSlice(slice []int, f func(int) int) []int {
	result := make([]int, len(slice))
	for i, v := range slice {
		result[i] = f(v)
	}
	return result
}
```

#### Filter

```go
func filterSlice(slice []int, predicate func(int) bool) []int {
	result := []int{}
	for _, v := range slice {
		if predicate(v) {
			result = append(result, v)
		}
	}
	return result
}
```

#### Reduce

```go
func reduceSlice(slice []int, f func(int, int) int, initial int) int {
	result := initial
	for _, v := range slice {
		result = f(result, v)
	}
	return result
}
```

---

## Working with the `github.com/samber/lo` Package

The [`github.com/samber/lo`](https://github.com/samber/lo) package is a library that extends Go's functional capabilities, offering utilities for working with *map*, *filter*, *reduce*, and other functional operations in a simpler and more efficient way. Next, we will see how to install and use this package.

### Installation

To install the package, use the following command:

```sh
go get github.com/samber/lo
```

### Usage Examples

#### Map

`lo.Map` allows you to transform a slice by applying a function to each element:

```go
package main

import (
	"fmt"
	"github.com/samber/lo"
)

func main() {
	numbers := []int{1, 2, 3, 4}
	squared := lo.Map(numbers, func(x int, _ int) int {
		return x * x
	})

	fmt.Println(squared) // [1, 4, 9, 16]
}
```

#### Filter

With `lo.Filter`, we can filter elements from a slice based on a condition:

```go
package main

import (
	"fmt"
	"github.com/samber/lo"
)

func main() {
	numbers := []int{1, 2, 3, 4}
	even := lo.Filter(numbers, func(x int, _ int) bool {
		return x%2 == 0
	})

	fmt.Println(even) // [2, 4]
}
```

#### Reduce

`lo.Reduce` allows you to accumulate values in a slice:

```go
package main

import (
	"fmt"
	"github.com/samber/lo"
)

func main() {
	numbers := []int{1, 2, 3, 4}
	sum := lo.Reduce(numbers, func(agg int, x int, _ int) int {
		return agg + x
	}, 0)

	fmt.Println(sum) // 10
}
```

#### Other Features

The package also offers utilities such as `lo.Uniq` to remove duplicates, `lo.FlatMap` to transform and flatten slices, among others. See the [official documentation](https://github.com/samber/lo) to explore all available features.

---

Although Go is not a purely functional language, it provides enough tools to incorporate elements of functional programming. Adopting these principles can lead to cleaner, more reusable code with fewer bugs. With practices such as using pure functions, composition, and immutability, and with the help of libraries such as `github.com/samber/lo`, developers can take advantage of the best of both worlds: Go's simplicity and the expressiveness of functional programming.
