---
title: Programação Funcional com Golang
description: A programação funcional (FP, do inglês *Functional Programming*) tem ganhado popularidade nos últimos anos devido à sua capacidade de criar código mais expressivo, modular e com...
date: "2025-01-28T17:23:39-03:00"
updated: ""
draft: false
tags:
    - functional-programming
    - go
url: /programacao-funcional-com-golang/
cover: cover.webp
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

A programação funcional (FP, do inglês *Functional Programming*) tem ganhado popularidade nos últimos anos devido à sua capacidade de criar código mais expressivo, modular e com menos efeitos colaterais. Go, apesar de ser uma linguagem projetada principalmente para o paradigma imperativo, possui diversas características que permitem adotar conceitos da programação funcional. Este artigo explora como aplicar princípios da programação funcional no desenvolvimento com Go.

---

## O que é Programação Funcional?

A programação funcional é um paradigma de desenvolvimento de software que enfatiza o uso de funções puras, imutabilidade e composição de funções. Diferentemente de paradigmas imperativos, onde o foco está na mutação de estado e no uso de comandos sequenciais, o paradigma funcional incentiva o uso de construções declarativas e a minimização de efeitos colaterais.

Os principais conceitos da programação funcional incluem:

1. **Funções Puras**: Uma função pura retorna sempre o mesmo resultado para os mesmos argumentos e não possui efeitos colaterais.
2. **Imutabilidade**: Os dados não são modificados após serem criados.
3. **Composição de Funções**: Combinação de funções menores para criar funcionalidades mais complexas.
4. **Funções de Alta Ordem**: Funções que aceitam outras funções como argumento ou retornam funções.
5. **Avaliação Preguiçosa (Lazy Evaluation)**: Avaliação de expressões apenas quando necessário (não diretamente suportado pelo Go).

---

## Programação Funcional em Go

Embora Go não seja uma linguagem funcional pura, ela suporta muitos dos princípios do paradigma funcional. Vamos explorar como isso pode ser feito na prática.

### Funções de Alta Ordem

Go permite que funções sejam tratadas como cidadãs de primeira classe. Isso significa que podemos passar funções como argumentos, retorná-las de outras funções ou armazená-las em variáveis.

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

Nesse exemplo, a função `applyOperation` aceita uma função como parâmetro e a utiliza para aplicar diferentes operações aos valores fornecidos.

### Funções Puras

Funções puras são aquelas que não dependem ou alteram o estado externo. Isso facilita o teste e a previsibilidade do código.

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

### Imutabilidade

Embora Go não tenha suporte nativo para imutabilidade como algumas linguagens funcionais (ex.: Haskell), é possível adotar boas práticas para evitar alterações desnecessárias no estado.

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

Neste exemplo, ao invés de modificar o slice original, criamos uma nova cópia com as alterações desejadas.

### Composição de Funções

Embora Go não tenha suporte nativo para composição de funções como outras linguagens (ex.: `pipe` em Elixir), podemos implementar nossa própria função de composição.

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

### Uso de Closures

Closures são funções que "lembram" o ambiente em que foram criadas. Em Go, closures são úteis para encapsular lógica.

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

### Trabalhando com Map, Filter e Reduce

Embora Go não tenha funções nativas como `map`, `filter` e `reduce` disponíveis em linguagens como Python ou JavaScript, podemos implementá-las.

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

## Trabalhando com o pacote `github.com/samber/lo`

O pacote [`github.com/samber/lo`](https://github.com/samber/lo) é uma biblioteca que estende as capacidades funcionais do Go, oferecendo utilitários para trabalhar com *map*, *filter*, *reduce* e outras operações funcionais de forma mais simples e eficiente. A seguir, veremos como instalar e usar este pacote.

### Instalação

Para instalar o pacote, use o seguinte comando:

```sh
go get github.com/samber/lo
```

### Exemplos de Uso

#### Map

O `lo.Map` permite transformar um slice aplicando uma função em cada elemento:

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

Com `lo.Filter`, podemos filtrar elementos de um slice com base em uma condição:

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

O `lo.Reduce` permite acumular valores em um slice:

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

#### Outras Funcionalidades

O pacote também oferece utilitários como `lo.Uniq` para remover duplicatas, `lo.FlatMap` para transformar e achatar slices, entre outros. Consulte a [documentação oficial](https://github.com/samber/lo) para explorar todas as funcionalidades disponíveis.

---

Embora Go não seja uma linguagem funcional pura, ela fornece ferramentas suficientes para incorporar elementos da programação funcional. Adotar esses princípios pode levar a um código mais limpo, reutilizável e com menos bugs. Com práticas como uso de funções puras, composição e imutabilidade, e o auxílio de bibliotecas como `github.com/samber/lo`, desenvolvedores podem aproveitar o melhor dos dois mundos: a simplicidade do Go e a expressividade da programação funcional.
