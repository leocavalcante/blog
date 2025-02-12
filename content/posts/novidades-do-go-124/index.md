---
title: Novidades do Go 1.24
description: A versão 1.24 da linguagem Go foi lançada em fevereiro de 2025, trazendo uma série de melhorias e novas funcionalidades que prometem aumentar a produtividade dos desenvolvedores...
date: "2025-02-12T15:57:00-03:00"
updated: ""
draft: false
tags:
    - go
url: /novidades-do-go-124/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

A versão 1.24 da linguagem Go foi lançada em fevereiro de 2025, trazendo uma série de melhorias e novas funcionalidades que prometem aumentar a produtividade dos desenvolvedores e otimizar o desempenho das aplicações. Neste artigo, vamos destacar algumas das principais novidades, como a nova diretiva `tool`, o suporte a generics em type aliases, a função `Loop` para testes de benchmark, melhorias de performance, suporte aprimorado ao WebAssembly e a nova função `AddCleanup`.

## 1\. Nova Diretiva `tool` para Gerenciamento de Dependências de Ferramentas

Uma das novidades mais interessantes do Go 1.24 é a introdução da diretiva `tool` no `go.mod`, que permite gerenciar dependências de ferramentas de forma mais eficiente. Anteriormente, era necessário adicionar ferramentas como imports em branco em um arquivo `tools.go`, o que podia ser um tanto incômodo. Agora, com a nova diretiva `tool`, você pode adicionar ferramentas diretamente no `go.mod` usando o comando `go get -tool`.

Por exemplo, para adicionar uma ferramenta chamada `golangci-lint`, você pode executar:

```bash
go get -tool github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.4
```

Isso adicionará uma diretiva `tool` ao seu `go.mod`, permitindo que você execute a ferramenta com o comando `go tool golangci-lint`. Além disso, todas as ferramentas declaradas no módulo podem ser atualizadas de uma só vez com `go get tool`.

Essa mudança simplifica o gerenciamento de ferramentas e torna o processo mais integrado ao fluxo de trabalho do Go.

## 2\. Suporte a Generics em Type Aliases

O Go 1.24 traz uma melhoria significativa no suporte a generics, permitindo que **type aliases** sejam parametrizados, assim como os tipos definidos. Isso significa que você pode agora criar aliases para tipos genéricos, o que aumenta a flexibilidade e a reutilização de código.

Por exemplo, você pode definir um alias para um tipo genérico da seguinte forma:

```go
type MyList[T any] = []T
```

Isso permite que você use `MyList` como um alias para uma lista genérica, simplificando a sintaxe e melhorando a legibilidade do código.

## 3\. Nova Função `Loop` em Testes de Benchmark

Outra adição importante no Go 1.24 é a nova função `Loop` para testes de benchmark. Anteriormente, os benchmarks eram escritos usando um loop `for` com `b.N`, o que podia ser propenso a erros e menos eficiente. Agora, você pode usar a função `Loop` para simplificar a execução de iterações de benchmark:

```go
for b.Loop() {
    // Código do benchmark
}
```

Essa abordagem é mais segura e eficiente, pois garante que o código de benchmark seja executado exatamente uma vez por iteração, evitando problemas comuns relacionados ao uso de `b.N`. Além disso, a função `Loop` mantém os parâmetros e resultados da função vivos, o que impede que o compilador otimize completamente o corpo do loop.

## 4\. Melhorias de Performance

O Go 1.24 traz várias melhorias de performance, especialmente no runtime. Entre as principais mudanças estão:

* **Nova implementação de mapas baseada em Swiss Tables**: Essa nova implementação reduz o overhead de CPU em 2-3% em benchmarks representativos.

* **Alocação de memória mais eficiente para pequenos objetos**: Isso resulta em uma redução no consumo de memória e em uma execução mais rápida para aplicações que lidam com muitos objetos pequenos.

* **Nova implementação de mutex interna**: O novo mutex é mais eficiente e menos propenso a erros, melhorando a concorrência em aplicações que dependem de sincronização.


Essas melhorias tornam o Go 1.24 uma escolha ainda mais atraente para aplicações de alto desempenho.

## 5\. Suporte Aprimorado ao WebAssembly

O suporte ao WebAssembly (Wasm) foi significativamente aprimorado no Go 1.24. Agora, você pode exportar funções Go para o host WebAssembly usando a nova diretiva `go:wasmexport`. Além disso, o Go 1.24 suporta a construção de programas Go como bibliotecas ou reatores no WebAssembly System Interface (WASI) usando o flag `-buildmode=c-shared`.

Essa melhoria facilita a integração de código Go em ambientes WebAssembly, permitindo que desenvolvedores criem aplicações web mais eficientes e interoperáveis.

## 6\. Nova Função `AddCleanup` para Finalização de Objetos

A função `runtime.AddCleanup` foi introduzida no Go 1.24 como uma alternativa mais flexível e eficiente ao `runtime.SetFinalizer`. Com `AddCleanup`, você pode anexar funções de limpeza a objetos que serão executadas quando o objeto não for mais alcançável.

A principal vantagem de `AddCleanup` é que ela permite múltiplas funções de limpeza para um único objeto, e essas funções podem ser anexadas a ponteiros internos. Além disso, `AddCleanup` não causa vazamentos de memória quando objetos formam ciclos, e não atrasa a liberação de memória.

Exemplo de uso:

```go
obj := &MyObject{}
runtime.AddCleanup(obj, func() {
    fmt.Println("Cleanup executed")
})
```

Essa nova função é uma adição valiosa para gerenciamento de recursos e limpeza de memória em aplicações Go.

## Em resumo

O Go 1.24 traz uma série de melhorias que reforçam a linguagem como uma das melhores escolhas para desenvolvimento de software moderno. Desde o gerenciamento simplificado de ferramentas com a diretiva `tool`, passando pelo suporte a generics em type aliases, até as melhorias de performance e suporte ao WebAssembly, essa versão oferece ferramentas poderosas para desenvolvedores.

A nova função `Loop` para benchmarks e a função `AddCleanup` para finalização de objetos são exemplos de como o Go continua evoluindo para atender às necessidades dos desenvolvedores, tornando a linguagem mais segura, eficiente e fácil de usar.

Se você ainda não experimentou o Go 1.24, agora é a hora de atualizar seu ambiente e explorar essas novas funcionalidades. A comunidade Go está mais ativa do que nunca, e com essas melhorias, a linguagem está pronta para enfrentar os desafios do desenvolvimento de software moderno.

[https://go.dev/blog/go1.24](https://go.dev/blog/go1.24)
[https://go.dev/doc/go1.24](https://go.dev/doc/go1.24)
