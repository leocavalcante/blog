---
title: 'Swiss Tables: O Segredo por Trás dos Maps Mais Rápidos do Go 1.24'
description: Os mapas (maps) no Go sempre foram uma das estruturas de dados mais utilizadas e otimizadas da linguagem. Com o lançamento do Go 1.24, eles ficaram ainda mais rápidos, graças à ...
date: "2025-03-05T12:16:02-03:00"
updated: ""
draft: false
tags:
    - go
    - performance
    - data-structures
    - releases
    - hash-tables
url: /swiss-tables-go-124/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Os mapas (maps) no Go sempre foram uma das estruturas de dados mais utilizadas e otimizadas da linguagem. Com o lançamento do Go 1.24, eles ficaram ainda mais rápidos, graças à implementação do conceito de Swiss Tables.

## Onde vivem e o que comem as Swiss Tables?

Swiss Tables são uma técnica avançada de hash table desenvolvida pelo Google para otimizar buscas e inserções em estruturas de dados baseadas em tabelas hash. Esse modelo foi originalmente implementado na biblioteca C++ Abseil e, desde então, inspirou melhorias em diversas linguagens e frameworks.

A principal inovação das Swiss Tables está na combinação de técnicas como:

* **Open Addressing** (*endereçamento aberto*): os elementos são armazenados diretamente na tabela, sem ponteiros adicionais.

* **SIMD Acceleration** (*uso de instruções vetoriais*): otimiza a busca simultânea em vários slots de uma vez.

* **Control Word** (*uso de metadados para indexação eficiente*): melhora a busca e minimiza colisões.


Exemplo:

```plaintext
Control Word: | 89 | 56 | 32 | 21 | - | - | - | - |
Slots:        | X  | X  | X  | X  |   |   |   |   |
```

O *Control Word* armazena os metadados sobre quais slots estão ocupados e quais podem ser utilizados, tornando as operações mais rápidas.

## Como funciona a estrutura das Swiss Tables?

A estrutura das Swiss Tables difere de uma hash table tradicional ao introduzir um **controle de metadados** que facilita buscas e minimiza colisões. Vamos detalhar seus principais componentes:

### 1\. Divisão em grupos

As chaves são armazenadas em um array dividido em **grupos de slots** (tipicamente 8 ou 16 slots por grupo). Cada grupo possui um bloco de controle que informa quais slots estão ocupados e quais podem ser usados.

### 2\. Control Word e sua relação com a RAM e CPU

Cada grupo de slots tem um **Control Word** de 64 bits, onde cada byte corresponde a um slot e contém informações sobre se o slot está vazio, ocupado ou foi deletado. Essa abordagem otimiza a utilização da memória RAM, pois permite um acesso mais eficiente aos dados, reduzindo *cache misses* e melhorando a localidade espacial dos dados armazenados.

A implementação do Control Word permite que os processadores modernos utilizem **instruções vetorizadas SIMD** para comparar múltiplos valores simultaneamente. Como resultado, a CPU pode verificar rapidamente quais slots estão disponíveis sem precisar iterar sequencialmente sobre todos os elementos. Esse modelo reduz significativamente a latência de busca e inserção, uma vantagem crucial para aplicações de alta performance.

### 3\. Comparação com SIMD

As buscas se tornam mais rápidas com **instruções SIMD** (*Single Instruction, Multiple Data*), que permitem comparar múltiplos valores simultaneamente ao operar sobre vários elementos de um vetor de dados em uma única instrução.

O processo funciona da seguinte forma:

1. **Carregamento do Control Word**: A CPU carrega um bloco de 64 bits contendo os metadados dos slots.

2. **Criação de um vetor de comparação**: Um vetor contendo o valor de hash buscado é replicado para que todos os bytes possam ser comparados simultaneamente.

3. **Aplicação da operação SIMD**: Uma única instrução realiza a comparação de todos os bytes do *Control Word* com o valor procurado.

4. **Extração dos resultados**: Um mapa de bits indica quais posições do vetor possuem correspondência com o hash buscado.


Exemplo:

```plaintext
Control Word:   | 89 | 56 | 32 | 21 | -- | -- | -- | -- |
Comparação SIMD | == | == | == | == | == | == | == | == |
                | 32 | 32 | 32 | 32 | 32 | 32 | 32 | 32 |
Resultado       |  0 |  0 |  1 |  0 |  0 |  0 |  0 |  0 |
```

Neste exemplo, a posição 3 contém o valor desejado, permitindo que a busca finalize rapidamente sem necessidade de iteração tradicional.

Essa técnica aproveita a capacidade das CPUs modernas de processar dados em paralelo, tornando buscas e inserções significativamente mais rápidas em comparação a tabelas hash tradicionais.

### 4\. Carga máxima ajustada

Como as buscas são mais eficientes, a Swiss Table pode operar com **uma carga maior antes da necessidade de redimensionamento**, o que melhora a eficiência de memória e reduz realocações.

## A implementação das Swiss Tables no Go 1.24

A introdução das Swiss Tables no Go 1.24 trouxe uma reestruturação completa da implementação dos maps. O novo modelo mantém a semântica dos mapas do Go, mas agora cada mapa é composto por **múltiplas tabelas independentes**, permitindo um crescimento mais eficiente.

### Melhorias na implementação do Go:

* **Busca mais rápida:** Graças ao *Control Word*, a busca por um item se tornou até **60% mais eficiente** em microbenchmarks.

* **Menos realocações:** O uso de grupos de slots reduz a necessidade de redimensionamento.

* **Melhor iteração:** Diferente de outras implementações, o Go permite modificar um mapa enquanto se itera sobre ele.


Exemplo prático:

```go
m := make(map[int]string)
m[1] = "Gopher"
m[2] = "Swiss Tables"
delete(m, 1)
fmt.Println(m[1]) // Saída: ""
```

## Por que isso torna o `map` em Go mais rápido?

O impacto da adoção das Swiss Tables no Go 1.24 pode ser resumido em três grandes vantagens:

1. **Maior eficiência nas buscas:** Graças ao *Control Word*, várias comparações são feitas simultaneamente.

2. **Menos colisões e realocações:** A estrutura melhora a distribuição de chaves.

3. **Uso otimizado de CPU:** O design das Swiss Tables aproveita ao máximo os processadores modernos, minimizando acessos desnecessários à memória RAM e reduzindo o tempo de execução das operações.


## Ou seja…

A implementação das Swiss Tables no Go 1.24 é um avanço significativo para a performance da linguagem. Com essa nova abordagem, os mapas se tornaram ainda mais eficientes, garantindo ganhos de velocidade para diversas aplicações.

Se você ainda não testou essa nova versão, vale a pena explorar e otimizar suas aplicações para aproveitar esses ganhos de performance!

---

Referência: [https://go.dev/blog/swisstable](https://go.dev/blog/swisstable)
