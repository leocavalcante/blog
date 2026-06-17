---
title: One Year of "Golanged"
description: Exactly one year ago, a commit with the message "Golanged" marked the beginning of a new phase in my career as a developer. It...
date: "2025-09-24T09:53:02-03:00"
updated: ""
draft: false
tags:
    - go
    - developer-experience
    - monorepo
    - career
    - pragmatism
url: /en/um-ano-de-golanged/
cover: cover.png
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Exactly one year ago, a commit with the message "Golanged" marked the beginning of a new phase in my career as a developer. It was my first step with the Go language in a professional project, inside a monorepo that I still maintain today. Little did I know that this word, almost a joke, would represent the discovery of a universe of possibilities. Today, I celebrate not only the date, but the decision to embark on this journey.

Go, or Golang, is a language that won me over through its **simplicity**, in the most powerful sense of the word. In a world of complex frameworks and multiple ways to reach the same result, Go offers a more direct path, almost a philosophy of "the right way to do it". And the most incredible part is how the developer community embraces this idea, creating an ecosystem of pragmatic engineers focused on building efficient and readable solutions.

---

### The Pillars of Go: Why does the language shine?

My experience over this year allowed me to experience in practice the benefits I had read so much about. If I had to summarize the high points of using Go, I would highlight:

* **Simplicity and Readability:** Go's syntax is lean and clear. With few keywords and standard formatting (thanks to `gofmt`), the code becomes incredibly easy to read and maintain. This speeds up onboarding for new developers and makes collaboration easier, since the code style is consistent across the entire codebase.

* **Exceptional Performance:** Go is a compiled language that generates native and optimized binaries. Compilation time is surprisingly fast, and runtime performance is fantastic, approaching languages like C++, but with much less complexity.

* **Native Concurrency:** This is perhaps Go's superpower. With **Goroutines** and **Channels**, writing concurrent code (that executes several tasks "at the same time") is trivial and safe. Instead of dealing with the complexity of threads and locks, Go offers an elegant model that simplifies the development of high-performance systems that make full use of modern processors.

* **Robust Standard Library:** Go comes with "batteries included". Its standard library is vast and covers everything from creating web servers (`net/http`) to cryptography and data manipulation tasks, reducing the need for external dependencies for essential functionality.


---

### Bonus: The Magic of the Monorepo (and no, it is not a Monolith!)

My journey with Go happened inside a **monorepo**, and that combination proved extremely powerful. It is crucial to clear up a common confusion: **monorepo is not synonymous with monolith**.

* A **monolith** is a *software architecture* where the entire application is a single large unit of code, tightly coupled.

* A **monorepo** is a *code versioning strategy* where multiple projects, libraries, and services (which can be microservices, for example) coexist in the same Git repository.


The advantages of working with a monorepo were clear from the beginning:

* **Simplified Code Sharing:** Reusing code between different services is as simple as importing a local package. There is no need to publish versions to a package registry and manage external dependencies.

* **Atomic Refactoring:** Need to change an API that is consumed by several services? In a monorepo, you can update the API and all its consumers in a single commit, ensuring that everything continues to work together.

* **Single Dependency Management:** All projects share the same dependency versions, avoiding "dependency hell" and ensuring consistency across the entire ecosystem.

* **Easier Collaboration:** Different teams have visibility into each other's code, which encourages collaboration and standardization of best practices.


### To wrap up

Looking back, that "Golanged" commit was more than just the beginning of a project. It was the start of a new way of thinking about software: simpler, more direct, and more pragmatic. The combination of Go's elegance with the organizational efficiency of a monorepo created a productive and pleasant development environment.

If you are looking for a language that values clarity, performance, and developer productivity, my one-year experience says loudly: give Go a chance. You may end up surprising yourself.
