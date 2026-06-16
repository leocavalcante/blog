---
title: 'Cobertura de Código em Testes de Go: Usando o covdata para Combinar Perfis'
description: Acho que uma das minhas maiores aventuras com Go tem sido trabalhar com testes. Foi com eles que mudei uma opinião com relação ao pragmatismo da linguagem, ela continua sendo su...
date: "2024-11-26T11:52:52-03:00"
updated: ""
draft: false
tags:
    - go
    - testing
    - code-coverage
    - tooling
    - quality-assurance
url: /cobertura-de-codigo-em-testes-de-go-usando-o-covdata-para-combinar-perfis/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Acho que uma das minhas maiores aventuras com Go tem sido trabalhar com testes. Foi com eles que mudei uma opinião com relação ao pragmatismo da linguagem, ela continua sendo super prática sim, ainda é bem simples e gostoso de programar, mas eu levava essa ideia de forma leviana a ponto de fazer as coisas de qualquer jeito e sem respeitar princípios da engenharia de software, que como o nome diz, são princípios, não dependem da linguagem e Go não está de fora dessa.

**Quem sabe exploro mais essa ideia em um outro artigo, mas nesse quero mostrar como foi conseguir combinar a cobertura de testes unitários e testes de integração.**

Acontece que a ferramenta que analisa a cobertura de código não separa as suítes de testes, então código exclusivo de infraestrutura, que seria coberto por um teste de integração, ainda entra na mesma análise dos testes unitários.
O que eu queria evitar é ter testes de integração sendo executados em conjunto de testes unitários por causa de uma limitação de uma ferramenta terceira (*Sonar, cof, cof...*).

E o ecossistema de Go surpreendendo mais uma vez: existe uma ferramenta do próprio Go que ajuda nesses casos, a `covdata`: https://pkg.go.dev/cmd/covdata

O primeiro passo foi separar o que era teste unitário de teste de integração, tenho usado o `make` pra ter essas execuções à mão:

```Makefile
.PHONY: unit-test
unit-test:
	go test -short -cover ./contract/... ./internal/cli/... ./internal/http/... -test.gocoverdir="${PWD}/test/cover/unit"

.PHONY: integration-test
integration-test:
	go test -short -cover ./internal/infra/... -test.gocoverdir="${PWD}/test/cover/integration"
```

Depois incluir um passo que faz o *merge* das duas coberturas:

```Makefile
.PHONY: cover
cover:
	go tool covdata textfmt -i=./test/cover/unit,./test/cover/integration -o cover.out
```

Agora sim a gente pode enviar o arquivo `cover.out` para a análise do Sonar:

```properties
sonar.go.coverage.reportPaths=cover.out
```

Ele combina a cobertura dos testes unitários e dos testes de integração.

Os testes de integração usam Testcontainers BTW, fica a dica de uma outra ótima ferramenta: https://testcontainers.com.
