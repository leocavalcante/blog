---
title: 'Code Coverage in Go Tests: Using covdata to Combine Profiles'
description: "I think one of my biggest adventures with Go has been working with tests. They changed one of my opinions about the language's pragmatism: it is still super..."
date: "2024-11-26T11:52:52-03:00"
updated: ""
draft: false
tags: []
url: /en/cobertura-de-codigo-em-testes-de-go-usando-o-covdata-para-combinar-perfis/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

I think one of my biggest adventures with Go has been working with tests. They changed one of my opinions about the language's pragmatism: yes, it is still super practical, still very simple and pleasant to program in, but I used to take that idea too lightly, to the point of doing things any which way and without respecting software engineering principles. As the name says, they are principles; they do not depend on the language, and Go is not exempt from them.

**Maybe I will explore that idea more in another article, but in this one I want to show how I managed to combine unit test and integration test coverage.**

It turns out that the tool that analyzes code coverage does not separate test suites, so infrastructure-only code, which would be covered by an integration test, still goes into the same analysis as the unit tests.
What I wanted to avoid was running integration tests together with unit tests because of a limitation in a third-party tool (*Sonar, cough, cough...*).

And the Go ecosystem surprised me once again: there is a tool from Go itself that helps in these cases, `covdata`: https://pkg.go.dev/cmd/covdata

The first step was to separate unit tests from integration tests. I have been using `make` to keep these executions handy:

```Makefile
.PHONY: unit-test
unit-test:
	go test -short -cover ./contract/... ./internal/cli/... ./internal/http/... -test.gocoverdir="${PWD}/test/cover/unit"

.PHONY: integration-test
integration-test:
	go test -short -cover ./internal/infra/... -test.gocoverdir="${PWD}/test/cover/integration"
```

Then add a step that merges the two coverage profiles:

```Makefile
.PHONY: cover
cover:
	go tool covdata textfmt -i=./test/cover/unit,./test/cover/integration -o cover.out
```

Now we can send the `cover.out` file to Sonar analysis:

```properties
sonar.go.coverage.reportPaths=cover.out
```

It combines the coverage from the unit tests and the integration tests.

The integration tests use Testcontainers BTW, so here is a tip for another great tool: https://testcontainers.com.
