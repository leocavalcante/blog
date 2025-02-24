---
title: 'Weak Pointers no Go 1.24: Entendendo e Aplicando na Prática'
description: O **Go 1.24** introduziu um novo pacote chamado `weak`, trazendo suporte para **weak pointers** (ponteiros fracos). Esses ponteiros permitem referenciar memória sem impedir sua ...
date: "2025-02-24T11:30:11-03:00"
updated: ""
draft: false
tags:
    - go
    - pointers-in-go
    - weak-pointer
url: /weak-pointers-no-go-124-entendendo-e-aplicando-na-pratica/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

O **Go 1.24** introduziu um novo pacote chamado `weak`, trazendo suporte para **weak pointers** (ponteiros fracos). Esses ponteiros permitem referenciar memória sem impedir sua coleta pelo **garbage collector (GC)**, tornando-se particularmente úteis para otimização de caches e redução de **memory leaks**.

Se você é um desenvolvedor experiente e quer entender como os **weak pointers** funcionam e quando utilizá-los, este artigo é para você.

---

## **O que são Weak Pointers?**

Um **weak pointer** é um tipo de referência para um objeto na memória que **não impede que o GC o remova** quando não há mais referências fortes a ele. Se o objeto for coletado, o ponteiro fraco se torna **nil** automaticamente.

### **As principais características são:**

- **Evita vazamentos de memória** ao permitir que objetos sejam coletados pelo GC mesmo se ainda existirem referências fracas.
- **Elimina riscos de ponteiros pendentes** (dangling pointers), pois quando um objeto é coletado, a referência fraca é automaticamente anulada.
- **Diferenciação entre referência forte e fraca:**
  - **Referências fortes:** Impedem a coleta do objeto.
  - **Referências fracas:** Permitem que o objeto seja coletado se não houver referências fortes.


## **Quando usar Weak Pointers?**

Os weak pointers não são necessários para a maioria dos casos no Go, pois o garbage collector gerencia a memória eficientemente. Mas... existem cenários onde eles são extremamente úteis:

1. **Otimização de caches:** evita que objetos permaneçam na memória quando não são mais usados.
2. **Gerenciamento de recursos compartilhados:** reduz o consumo de memória sem exigir controle manual.
3. **Prevenção de vazamentos de memória:** permite que objetos não referenciados sejam removidos automaticamente.

Agora, vamos aplicar esse conceito na prática.

---

## **Implementando um Cache com e sem Weak Pointers**

Vamos implementar um cache simples para entender como o uso de weak pointers impacta o gerenciamento de memória.

### **Cache sem Weak Pointers (com vazamento de memória)**

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

### **Saída esperada:**
Mesmo após chamar `runtime.GC()`, a memória alocada continua a mesma, pois a referência ainda existe no cache.

```text
Alloc =  2197336
Alloc =  2209696
```

---

## **Cache com Weak Pointers (sem vazamento de memória)**

Agora, vamos modificar nosso cache para usar weak pointers.
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

Resultado final
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

### **Saída esperada:**
Agora, após a coleta do GC, a memória é reduzida, pois o `data` foi corretamente removido do cache.
```text
Alloc =  2197336
Alloc =  202544
```

---

## **Resumindo**

O **pacote weak no Go 1.24** permite criar **weak pointers**, ajudando a reduzir vazamentos de memória sem precisar gerenciar manualmente os objetos referenciados. No exemplo acima, vimos como isso impacta caches, um dos principais casos de uso dessa funcionalidade.

### **Boas práticas ao usar Weak Pointers:**
- **Sempre verifique se o valor é nil** antes de acessá-lo.
- **Evite overuse**: use weak pointers apenas quando necessário para evitar complexidade desnecessária.
- **Remova chaves de cache que apontam para valores coletados pelo GC** para evitar referências mortas.

Com essas práticas, você pode melhorar a eficiência da memória em aplicações Go!

---

Se você quer se aprofundar ainda mais, explore a documentação oficial do Go 1.24 e teste os exemplos no seu próprio código!
https://pkg.go.dev/weak
