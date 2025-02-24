---
title: 'Weak Pointers in Go 1.24: Understanding and Applying Them in Practice'
description: "**Go 1.24** introduced a new package called `weak`, bringing support for **weak pointers**. These pointers make it possible to reference..."
date: "2025-02-24T11:30:11-03:00"
updated: ""
draft: false
tags:
    - go
    - pointers-in-go
    - weak-pointer
url: /en/weak-pointers-no-go-124-entendendo-e-aplicando-na-pratica/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

**Go 1.24** introduced a new package called `weak`, bringing support for **weak pointers**. These pointers make it possible to reference memory without preventing its collection by the **garbage collector (GC)**, making them particularly useful for cache optimization and reducing **memory leaks**.

If you are an experienced developer and want to understand how **weak pointers** work and when to use them, this article is for you.

---

## **What are Weak Pointers?**

A **weak pointer** is a type of reference to an object in memory that **does not prevent the GC from removing it** when there are no more strong references to it. If the object is collected, the weak pointer automatically becomes **nil**.

### **The main characteristics are:**

- **Avoids memory leaks** by allowing objects to be collected by the GC even if weak references still exist.
- **Eliminates dangling pointer risks**, because when an object is collected, the weak reference is automatically cleared.
- **Distinction between strong and weak references:**
  - **Strong references:** Prevent the object from being collected.
  - **Weak references:** Allow the object to be collected if there are no strong references.


## **When should you use Weak Pointers?**

Weak pointers are not necessary for most cases in Go, because the garbage collector manages memory efficiently. But... there are scenarios where they are extremely useful:

1. **Cache optimization:** prevents objects from remaining in memory when they are no longer used.
2. **Shared resource management:** reduces memory consumption without requiring manual control.
3. **Memory leak prevention:** allows unreferenced objects to be removed automatically.

Now, let's apply this concept in practice.

---

## **Implementing a Cache with and without Weak Pointers**

Let's implement a simple cache to understand how the use of weak pointers impacts memory management.

### **Cache without Weak Pointers (with memory leak)**

```go
package main

import (
	"runtime"
	"strings"
)

type Data struct {
	Value string
}

type Cache struct {
	Items map[string]*Data
}

func NewCache() *Cache {
	return &Cache{
		Items: make(map[string]*Data),
	}
}

func (c *Cache) Set(k string, d *Data) {
	c.Items[k] = d
}

func (c *Cache) Get(k string) *Data {
	return c.Items[k]
}

func main() {
	d := &Data{
		Value: strings.Repeat("Go", 1_000_000),
	}

	cache := NewCache()
	cache.Set("data", d)

	memUsage()

	d = nil
	runtime.GC()

	useData(cache.Get("data"))

	memUsage()
}

func useData(d *Data) {
	// Ponto que irá utilizar o dado
}

func memUsage() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	println("Alloc = ", m.Alloc)
}
```

### **Expected output:**
Even after calling `runtime.GC()`, the allocated memory remains the same because the reference still exists in the cache.

```text
Alloc =  2197336
Alloc =  2209696
```

---

## **Cache with Weak Pointers (without memory leak)**

Now, let's modify our cache to use weak pointers.
```shell
git diff memoryleak..weakpointer
```

```diff
import (
        "runtime"
        "strings"
+       "weak"
)

type Cache struct {
-       Items map[string]*Data
+       Items map[string]weak.Pointer[Data]
}

func NewCache() *Cache {
        return &Cache{
-               Items: make(map[string]*Data),
+               Items: make(map[string]weak.Pointer[Data]),
        }
}

func (c *Cache) Set(k string, d *Data) {
-       c.Items[k] = d
+       c.Items[k] = weak.Make(d)
}

func (c *Cache) Get(k string) *Data {
-       return c.Items[k]
+       return c.Items[k].Value()
}
```

Final result
```go
package main

import (
	"runtime"
	"strings"
	"weak"
)

type Data struct {
	Value string
}

type Cache struct {
	Items map[string]weak.Pointer[Data]
}

func NewCache() *Cache {
	return &Cache{
		Items: make(map[string]weak.Pointer[Data]),
	}
}

func (c *Cache) Set(k string, d *Data) {
	c.Items[k] = weak.Make(d)
}

func (c *Cache) Get(k string) *Data {
	return c.Items[k].Value()
}

func main() {
	d := &Data{
		Value: strings.Repeat("Go", 1_000_000),
	}

	cache := NewCache()
	cache.Set("data", d)

	memUsage()

	d = nil
	runtime.GC()

	useData(cache.Get("data"))

	memUsage()
}

func useData(d *Data) {
	// Ponto que irá utilizar o dado
}

func memUsage() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	println("Alloc = ", m.Alloc)
}
```

### **Expected output:**
Now, after GC collection, memory is reduced because `data` was correctly removed from the cache.
```text
Alloc =  2197336
Alloc =  202544
```

---

## **Summary**

The **weak package in Go 1.24** allows you to create **weak pointers**, helping reduce memory leaks without needing to manually manage referenced objects. In the example above, we saw how this impacts caches, one of the main use cases for this feature.

### **Best practices when using Weak Pointers:**
- **Always check whether the value is nil** before accessing it.
- **Avoid overuse**: use weak pointers only when necessary to avoid unnecessary complexity.
- **Remove cache keys that point to values collected by the GC** to avoid dead references.

With these practices, you can improve memory efficiency in Go applications!

---

If you want to go even deeper, explore the official Go 1.24 documentation and test the examples in your own code!
https://pkg.go.dev/weak
