---
title: Taking AI Engineering to the Next Level with RAG
description: If you are starting to venture into AI Engineering and want to go beyond the basics, you need to deeply understand what **Retrieval-Augmented Generation (RAG)** is.
date: "2025-11-28T15:58:03-03:00"
updated: ""
draft: false
tags:
    - ai
    - ai-engineering
    - artificial-intelligence
    - chunking
    - rag
    - reranking
url: /en/levando-ai-engineering-para-o-proximo-nivel-com-rag/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

If you are starting to venture into the world of AI Engineering and want to go beyond the basics, you need to deeply understand what **Retrieval-Augmented Generation (RAG)** is. This technique is, without a doubt, a turning point for anyone who wants to build AI agents that actually deliver solid results with user- and company-specific data.

## Why does RAG matter?

Let us be direct: training a Large Language Model (LLM) from scratch is absurdly expensive. We are talking about millions of dollars in infrastructure, energy, and time. For most companies, that is simply not viable. And this is exactly where RAG comes in as an elegant and practical solution.

RAG combines the generative power of LLMs with information retrieval systems, allowing you to "teach" the model about your specific domain without having to retrain it. Imagine you have an internal knowledge base with company policies, technical documentation, or customer data. With RAG, you can connect that base directly to the LLM, making it respond in a contextualized and accurate way.

But the benefits go far beyond savings. LLMs have a serious problem called **hallucination**, where they invent information that seems true but is completely fabricated. RAG drastically mitigates this problem because it forces the model to base its answers on real documents retrieved from your knowledge base. The model stops "making things up" and starts "citing sources".

Another critical point is the **knowledge cutoff**. LLMs are trained up to a specific date and know nothing about later events. With RAG, you can feed the system with real-time updated information simply by adding new documents to your index. No retraining, no astronomical costs.

## The basic architecture: understanding the flow

Before diving into advanced techniques, we need to understand how a RAG pipeline works. The process is divided into two main phases.

In the first phase, called **Indexing**, you prepare your data. This involves loading documents from different sources such as PDFs, web pages, or internal databases, splitting those documents into smaller pieces called **chunks**, converting each chunk into a numerical representation called an **embedding** using a specialized model, and finally storing those embeddings in a **vector database** such as ChromaDB, Pinecone, or Weaviate.

The second phase is **Retrieval-Generation**, which happens when the user asks a question. The user's query is converted into an embedding, that embedding is compared with the stored embeddings to find the most similar chunks, the retrieved chunks are inserted into the prompt together with the original question, and the LLM generates an answer based on that enriched context.

Sounds simple, right? Conceptually, it is. But the difference between a RAG system that works "more or less" and one that delivers spectacular results is in the implementation details. And that is where advanced techniques come in.

## Moving 2 squares forward

When we talk about **Advanced RAG** or **Context Engineering**, we are talking about a mindset shift. It is no longer about writing better prompts, it is about architecting entire systems that ensure the LLM receives exactly the right information, in the right format, at the right time.

One powerful technique is **Hybrid Retrieval**, which combines semantic search via vectors with keyword search using algorithms like BM25. This ensures you capture results both when the exact words differ and when they need to be exactly the same. Studies show that hybrid search can reduce answer errors by up to 40%.

Another approach is **Query Rewriting**, where you use the LLM itself to transform vague or complex questions into more effective search queries. This is especially useful when users ask ambiguous or poorly phrased questions.

**GraphRAG** is an interesting evolution that converts unstructured data into knowledge graphs. This allows the LLM to reason about relationships between entities, something simple vector search does not do well. Imagine asking "which employees who report to manager X worked on project Y?" - this requires understanding relationships, not just semantic similarity.

And of course, we have **Agentic RAG**, where the LLM is no longer passive. It dynamically decides when and how to search for information, and can access multiple sources such as SQL databases, web APIs, or different vector stores. It is the first step toward building truly autonomous agents.

But of all these techniques, two deserve special attention because they directly impact the quality of your system: **Chunking** and **Re-ranking**.

## Chunking: the foundation that defines your ceiling

To be very clear: the quality of your chunking defines the maximum performance limit of your RAG system. It does not matter how sophisticated your embedding model is or how powerful your LLM is; if you feed the system poorly built chunks, the result will be mediocre. It is the classic "garbage in, garbage out".

Chunking is the process of splitting large documents into smaller pieces that will be individually indexed and retrieved. It seems trivial, but the way you do it has deep implications.

First, there is a technical issue: embeddings are numerical representations of content, and embedding models have token limits they can process. Second, the LLM has a limited context window, so you need chunks that fit inside that window. Third, and most importantly, chunks that are too large dilute relevance, and chunks that are too small lose essential context.

The ideal size is usually between 256 and 512 tokens, with a 10 to 20% overlap between consecutive chunks. But this is only a starting point. The optimal size depends on your domain, the types of questions users ask, and the nature of your documents. It is an iterative engineering problem, not a magic formula.

The most basic strategy is **Fixed-Size Chunking**, where you simply cut the text every N characters. It is fast and simple, but often cuts sentences in half, separating ideas that should stay together. The result is fragmented and incoherent chunks.

A significant evolution is **Recursive Character Text Splitting**, which is considered the go-to method for most cases. It uses a hierarchy of separators such as paragraphs, line breaks, and spaces, trying to keep semantic units together. Only when it cannot respect the size limit using one separator does it move to the next in the hierarchy.

For well-structured documents, **Structure-Aware Chunking** may be the biggest performance improvement with the least effort. If you have Markdown with clear headers, code organized into functions, or semantic HTML, it makes complete sense to use those natural delimiters instead of ignoring them.

**Semantic Chunking** goes one step further. It calculates vector similarity between adjacent sentences and only breaks the chunk when it detects a significant topic change. This ensures high semantic cohesion within each chunk, which is especially valuable for knowledge bases and research papers.

One particularly elegant technique is **Small-to-Large Chunking**, also known as Parent Document Retriever. The idea is to use small and precise chunks for retrieval, ensuring high search precision, but when a chunk is found, you retrieve the larger "parent" chunk to give the LLM rich context. It is the best of both worlds.

Let us see how to implement Recursive Character Text Splitting using LangChain:

```python
from langchain.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Carregando o documento
loader = PyPDFLoader("documento_com_dominio_especifico.pdf")
documents = loader.load()

# Configurando o splitter com a estratégia recursiva
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=100,
    separators=["\n\n", "\n", " ", ""]
)

# Aplicando o splitting
chunks = text_splitter.split_documents(documents)

print(f"Documento dividido em {len(chunks)} chunks")
```

The `separators` parameter is where the magic happens. The algorithm first tries to split on double paragraphs, then on single line breaks, then on spaces, and only as a last resort makes arbitrary cuts. This preserves the semantic structure of the original text.

The `chunk_overlap` is crucial so context is not lost at the edges. If important information is at the end of one chunk and referenced at the beginning of the next, the overlap ensures that this connection is maintained in at least one of the chunks.

## Re-ranking: the quality filter

If chunking is the foundation, re-ranking is the quality control that ensures only the best material reaches the LLM. And that is more important than it seems.

When you run a vector search, the system returns the N most similar documents based on cosine distance or another metric. But here is the problem: embedding similarity is only a rough approximation of real relevance. The process of converting text into vectors inevitably loses information, and two texts can have similar embeddings without being truly relevant to the specific query.

That is where re-ranking comes in. After retrieving an initially broad set of candidates, say 10 or 20 chunks, a specialized model reevaluates each of them against the original query and assigns a refined relevance score. The chunks are then reordered based on these new scores, and only the best ones, maybe 3 or 4, are passed to the LLM.

The most common technique for re-ranking uses **Cross-Encoders**. Unlike the bi-encoders used to create embeddings, which process query and document separately, cross-encoders process both together. This allows a much deeper analysis of the relationship between the question and the content, resulting in much more precise relevance scores.

The trade-off is that cross-encoders are slower because they need to process each query-document pair individually. That is why we use them in two stages: first a fast vector search to get many candidates, then slower but more precise re-ranking to filter the best ones.

See how to implement this in practice:

```python
from langchain.embeddings import OpenAIEmbeddings
from langchain_chroma import Chroma
from sentence_transformers import CrossEncoder

# Primeiro, criamos o vectorstore com os chunks
embeddings = OpenAIEmbeddings(model="text-embedding-ada-002")
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# Query do usuário
query = "Qual é a política de cancelamento de voos?"

# Retrieval inicial com K alto para ter candidatos suficientes
candidatos = vectorstore. similarity_search(query, k=10)

# Agora aplicamos re-ranking com Cross-Encoder
cross_encoder = CrossEncoder('cross-encoder/ms-marco-MiniLM-L-6-v2')

# Preparando os pares query-documento
pares = [[query, doc. page_content] for doc in candidatos]

# Calculando scores refinados
scores = cross_encoder.predict(pares)

# Combinando scores com documentos e ordenando
docs_com_score = list(zip(scores, candidatos))
docs_ordenados = sorted(docs_com_score, key=lambda x: x[0], reverse=True)

# Selecionando apenas os top para o LLM
top_chunks = [doc for score, doc in docs_ordenados[:4]]

print(f"Selecionados {len(top_chunks)} chunks após re-ranking")
```

The model `cross-encoder/ms-marco-MiniLM-L-6-v2` is a solid choice to start with. It is relatively small and fast, but still offers a significant improvement over relying only on vector similarity scores.

## Putting it all together

Now let us see how all these components connect in a complete and functional RAG pipeline:

```python
from langchain. document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain_chroma import Chroma
from langchain.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain. chains. combine_documents import create_stuff_documents_chain
from sentence_transformers import CrossEncoder

# FASE 1: Indexing com Advanced Chunking
loader = PyPDFLoader("base_conhecimento.pdf")
documents = loader.load()

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=100,
    separators=["\n\n", "\n", " ", ""]
)
chunks = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings(model="text-embedding-ada-002")
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=embeddings,
    persist_directory="./chroma_db"
)

# FASE 2: Retrieval com Re-ranking
query = "Como funciona o processo de reembolso?"

candidatos = vectorstore.similarity_search(query, k=10)

cross_encoder = CrossEncoder('cross-encoder/ms-marco-MiniLM-L-6-v2')
pares = [[query, doc.page_content] for doc in candidatos]
scores = cross_encoder. predict(pares)

docs_ordenados = sorted(zip(scores, candidatos), key=lambda x: x[0], reverse=True)
contexto_final = [doc for score, doc in docs_ordenados[:4]]

# FASE 3: Generation
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

prompt = ChatPromptTemplate.from_template("""
Responda a pergunta baseando-se APENAS no contexto fornecido.
Se o contexto não contiver a informação necessária, diga claramente
que não foi possível encontrar a resposta.

Contexto: {context}

Pergunta: {input}
""")

chain = create_stuff_documents_chain(llm, prompt)

resposta = chain.invoke({
    "input": query,
    "context": contexto_final
})

print(resposta)
```

This code represents a robust RAG system that goes far beyond the basics. You have intelligent chunking that preserves semantic context, retrieval that searches for broad candidates, re-ranking that filters only the best ones, and generation that forces the model to rely on the provided context.

## In other words

Mastering RAG is essential for any AI Engineer who wants to build serious production systems. It is no longer about writing pretty prompts, it is about architecting pipelines that guarantee consistent and reliable quality.

The techniques we explored here, especially advanced chunking and re-ranking, are the kind of knowledge that separates amateur implementations from enterprise-grade systems. And the best part is that frameworks like LangChain make implementation accessible, allowing you to focus on architecture and optimization instead of reinventing the wheel.

The natural next step is to explore even more advanced techniques such as Agentic RAG, where the system autonomously decides when and how to search for information, and GraphRAG for cases that require reasoning over complex relationships. But with the foundation we built here, you are already prepared to deliver results that truly impress.

The journey from prompt engineering to Context Engineering is a necessary evolution. And now you have the tools to make that transition.
