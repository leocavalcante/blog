---
title: "Swiss Tables: The Secret Behind Go 1.24's Faster Maps"
description: Maps in Go have always been one of the language's most widely used and optimized data structures. With the release of Go 1.24, they...
date: "2025-03-05T12:16:02-03:00"
updated: ""
draft: false
tags:
    - go
    - performance
    - data-structures
    - releases
    - hash-tables
url: /en/swiss-tables-go-124/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Maps in Go have always been one of the language's most widely used and optimized data structures. With the release of Go 1.24, they became even faster thanks to the implementation of the Swiss Tables concept.

## Where do Swiss Tables live, and what do they eat?

Swiss Tables are an advanced hash table technique developed by Google to optimize lookups and insertions in data structures based on hash tables. This model was originally implemented in the C++ Abseil library and has since inspired improvements in several languages and frameworks.

The main innovation of Swiss Tables lies in the combination of techniques such as:

* **Open Addressing** (*endereçamento aberto*): elements are stored directly in the table, without additional pointers.

* **SIMD Acceleration** (*uso de instruções vetoriais*): optimizes simultaneous lookup across several slots at once.

* **Control Word** (*uso de metadados para indexação eficiente*): improves lookup and minimizes collisions.


Example:

```plaintext
Control Word: | 89 | 56 | 32 | 21 | - | - | - | - |
Slots:        | X  | X  | X  | X  |   |   |   |   |
```

The *Control Word* stores metadata about which slots are occupied and which can be used, making operations faster.

## How does the Swiss Tables structure work?

The Swiss Tables structure differs from a traditional hash table by introducing **metadata control** that makes lookups easier and minimizes collisions. Let's detail its main components:

### 1\. Division into groups

Keys are stored in an array divided into **groups of slots** (typically 8 or 16 slots per group). Each group has a control block that indicates which slots are occupied and which can be used.

### 2\. Control Word and its relationship with RAM and CPU

Each group of slots has a 64-bit **Control Word**, where each byte corresponds to a slot and contains information about whether the slot is empty, occupied, or deleted. This approach optimizes RAM usage because it allows more efficient access to data, reducing *cache misses* and improving the spatial locality of stored data.

The Control Word implementation allows modern processors to use **SIMD vectorized instructions** to compare multiple values simultaneously. As a result, the CPU can quickly check which slots are available without needing to iterate sequentially over all elements. This model significantly reduces lookup and insertion latency, a crucial advantage for high-performance applications.

### 3\. SIMD comparison

Lookups become faster with **SIMD instructions** (*Single Instruction, Multiple Data*), which allow multiple values to be compared simultaneously by operating on several elements of a data vector in a single instruction.

The process works as follows:

1. **Loading the Control Word**: The CPU loads a 64-bit block containing the slot metadata.

2. **Creating a comparison vector**: A vector containing the searched hash value is replicated so that all bytes can be compared simultaneously.

3. **Applying the SIMD operation**: A single instruction compares all bytes of the *Control Word* with the searched value.

4. **Extracting the results**: A bitmap indicates which vector positions match the searched hash.


Example:

```plaintext
Control Word:   | 89 | 56 | 32 | 21 | -- | -- | -- | -- |
Comparação SIMD | == | == | == | == | == | == | == | == |
                | 32 | 32 | 32 | 32 | 32 | 32 | 32 | 32 |
Resultado       |  0 |  0 |  1 |  0 |  0 |  0 |  0 |  0 |
```

In this example, position 3 contains the desired value, allowing the lookup to finish quickly without traditional iteration.

This technique takes advantage of modern CPUs' ability to process data in parallel, making lookups and insertions significantly faster compared with traditional hash tables.

### 4\. Adjusted maximum load

Because lookups are more efficient, the Swiss Table can operate with **a higher load before resizing is needed**, which improves memory efficiency and reduces reallocations.

## The Swiss Tables implementation in Go 1.24

The introduction of Swiss Tables in Go 1.24 brought a complete restructuring of the map implementation. The new model keeps the semantics of Go maps, but now each map is composed of **multiple independent tables**, allowing more efficient growth.

### Improvements in the Go implementation:

* **Faster lookup:** Thanks to the *Control Word*, looking up an item became up to **60% more efficient** in microbenchmarks.

* **Fewer reallocations:** The use of slot groups reduces the need for resizing.

* **Better iteration:** Unlike other implementations, Go allows modifying a map while iterating over it.


Practical example:

```go
m := make(map[int]string)
m[1] = "Gopher"
m[2] = "Swiss Tables"
delete(m, 1)
fmt.Println(m[1]) // Saída: ""
```

## Why does this make Go's `map` faster?

The impact of adopting Swiss Tables in Go 1.24 can be summarized in three major advantages:

1. **Greater lookup efficiency:** Thanks to the *Control Word*, several comparisons are made simultaneously.

2. **Fewer collisions and reallocations:** The structure improves key distribution.

3. **Optimized CPU usage:** The Swiss Tables design makes the most of modern processors, minimizing unnecessary RAM accesses and reducing operation execution time.


## In other words...

The implementation of Swiss Tables in Go 1.24 is a significant advance for the language's performance. With this new approach, maps became even more efficient, guaranteeing speed gains for many applications.

If you have not tested this new version yet, it is worth exploring and optimizing your applications to take advantage of these performance gains!

---

Reference: [https://go.dev/blog/swisstable](https://go.dev/blog/swisstable)
