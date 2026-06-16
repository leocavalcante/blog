---
title: Levando AI Engineering para o próximo nível com RAG
description: Se você está começando a se aventurar no mundo de AI Engineering e quer ir além do básico, precisa entender profundamente o que é **Retrieval-Augmented Generation (RAG)**. Essa ...
date: "2025-11-28T15:58:03-03:00"
updated: ""
draft: false
tags:
    - ai
    - rag
    - llm
    - retrieval
    - engineering
url: /levando-ai-engineering-para-o-proximo-nivel-com-rag/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Se você está começando a se aventurar no mundo de AI Engineering e quer ir além do básico, precisa entender profundamente o que é **Retrieval-Augmented Generation (RAG)**. Essa técnica é, sem dúvida, um divisor de águas para quem quer construir agentes de IA que realmente entregam resultados bacanas com dados específicos de usuários e empresas.

## Por que RAG importa?

Vamos ser diretos: treinar um Large Language Model (LLM) do zero é absurdamente caro. Estamos falando de milhões de dólares em infraestrutura, energia e tempo. Para a maioria das empresas, isso simplesmente não é viável. E é exatamente aqui que o RAG entra como uma solução elegante e prática.

O RAG combina o poder generativo dos LLMs com sistemas de recuperação de informação, permitindo que você "ensine" o modelo sobre seu domínio específico sem precisar retreiná-lo. Imagine que você tem uma base de conhecimento interna com políticas da empresa, documentação técnica ou dados de clientes. Com RAG, você pode conectar essa base diretamente ao LLM, fazendo com que ele responda de forma contextualizada e precisa.

Mas os benefícios vão muito além da economia. LLMs têm um problema sério chamado **hallucination**, onde eles inventam informações que parecem verdadeiras mas são completamente fabricadas. O RAG mitiga drasticamente esse problema porque força o modelo a basear suas respostas em documentos reais que foram recuperados da sua base de conhecimento. O modelo deixa de "inventar" e passa a "citar fontes".

Outro ponto crítico é o **knowledge cutoff**. Os LLMs são treinados até uma data específica e não sabem nada sobre eventos posteriores. Com RAG, você pode alimentar o sistema com informações atualizadas em tempo real, simplesmente adicionando novos documentos ao seu índice. Nada de retreinamento, nada de custos astronômicos.

## A arquitetura básica: entendendo o fluxo

Antes de mergulharmos nas técnicas avançadas, precisamos entender como um pipeline RAG funciona. O processo se divide em duas fases principais.

Na primeira fase, chamada de **Indexing**, você prepara seus dados. Isso envolve carregar documentos de diversas fontes como PDFs, páginas web ou bases de dados internas, dividir esses documentos em pedaços menores chamados **chunks**, converter cada chunk em uma representação numérica chamada **embedding** usando um modelo especializado, e finalmente armazenar esses embeddings em um **vector database** como ChromaDB, Pinecone ou Weaviate.

A segunda fase é a **Retrieval-Generation**, que acontece quando o usuário faz uma pergunta. A query do usuário é convertida em um embedding, esse embedding é comparado com os embeddings armazenados para encontrar os chunks mais similares, os chunks recuperados são inseridos no prompt junto com a pergunta original, e o LLM gera uma resposta baseada nesse contexto enriquecido.

Parece simples, certo? E conceitualmente é. Mas a diferença entre um RAG que funciona "mais ou menos" e um que entrega resultados espetaculares está nos detalhes de implementação. E é aí que entram as técnicas avançadas.

## Avançando 2 casas

Quando falamos de **Advanced RAG** ou **Context Engineering**, estamos falando de uma mudança de mentalidade. Não é mais sobre escrever prompts melhores, é sobre arquitetar sistemas inteiros que garantem que o LLM receba exatamente a informação certa, no formato certo, na hora certa.

Uma técnica poderosa é o **Hybrid Retrieval**, que combina busca semântica via vectors com busca por keywords usando algoritmos como BM25. Isso garante que você capture resultados mesmo quando as palavras exatas são diferentes, mas também quando precisam ser exatamente iguais. Estudos mostram que hybrid search pode reduzir erros de resposta em até 40%.

Outra abordagem é o **Query Rewriting**, onde você usa o próprio LLM para transformar perguntas vagas ou complexas em queries mais efetivas para busca. Isso é especialmente útil quando usuários fazem perguntas ambíguas ou mal formuladas.

O **GraphRAG** é uma evolução interessante que converte dados não estruturados em knowledge graphs. Isso permite que o LLM raciocine sobre relacionamentos entre entidades, algo que busca vetorial simples não consegue fazer bem. Imagine perguntar "quais funcionários que reportam ao gerente X trabalharam no projeto Y?" - isso requer entender relações, não apenas similaridade semântica.

E claro, temos o **Agentic RAG**, onde o LLM não é mais passivo. Ele decide dinamicamente quando e como buscar informação, podendo acessar múltiplas fontes como databases SQL, APIs web ou diferentes vector stores. É o primeiro passo para construir agentes verdadeiramente autônomos.

Mas de todas essas técnicas, duas merecem atenção especial porque impactam diretamente a qualidade do seu sistema: **Chunking** e **Re-ranking**.

## Chunking: a fundação que define seu teto

Sendo bem claro: a qualidade do seu chunking define o limite máximo de performance do seu sistema RAG. Não importa quão sofisticado seja seu modelo de embedding ou quão poderoso seja seu LLM, se você alimentar o sistema com chunks mal construídos, o resultado será medíocre. É o clássico "garbage in, garbage out".

Chunking é o processo de dividir documentos grandes em pedaços menores que serão individualmente indexados e recuperados. Parece trivial, mas a forma como você faz isso tem implicações profundas.

Primeiro, existe uma questão técnica: embeddings são representações numéricas de conteúdo, e modelos de embedding têm limites de tokens que podem processar. Segundo, o LLM tem uma context window limitada, então você precisa de chunks que caibam nessa janela. Terceiro, e mais importante, chunks muito grandes diluem a relevância e chunks muito pequenos perdem contexto essencial.

O tamanho ideal geralmente fica entre 256 e 512 tokens, com um overlap de 10 a 20% entre chunks consecutivos. Mas isso é apenas um ponto de partida. O tamanho ótimo depende do seu domínio, do tipo de perguntas que os usuários fazem e da natureza dos seus documentos. É um problema de engenharia iterativa, não uma fórmula mágica.

A estratégia mais básica é o **Fixed-Size Chunking**, onde você simplesmente corta o texto a cada N caracteres. É rápido e simples, mas frequentemente corta frases no meio, separando ideias que deveriam estar juntas. O resultado são chunks fragmentados e incoerentes.

Uma evolução significativa é o **Recursive Character Text Splitting**, que é considerado o método go-to para a maioria dos casos. Ele usa uma hierarquia de separadores como parágrafos, quebras de linha e espaços, tentando manter unidades semânticas juntas. Só quando não consegue respeitar o limite de tamanho usando um separador, ele passa para o próximo na hierarquia.

Para documentos bem estruturados, o **Structure-Aware Chunking** pode ser a maior melhoria de performance com o menor esforço. Se você tem Markdown com headers claros, código organizado em funções ou HTML semântico, faz todo sentido usar esses delimitadores naturais ao invés de ignorá-los.

O **Semantic Chunking** vai um passo além. Ele calcula a similaridade vetorial entre sentenças adjacentes e só quebra o chunk quando detecta uma mudança significativa de tópico. Isso garante alta coesão semântica dentro de cada chunk, o que é especialmente valioso para knowledge bases e papers de pesquisa.

Uma técnica particularmente elegante é o **Small-to-Large Chunking**, também conhecido como Parent Document Retriever. A ideia é usar chunks pequenos e precisos para retrieval, garantindo alta precisão na busca, mas quando um chunk é encontrado, você recupera o chunk "pai" maior para dar contexto rico ao LLM. É o melhor dos dois mundos.

Vamos ver como implementar o Recursive Character Text Splitting usando LangChain:

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

O parâmetro `separators` é onde a mágica acontece. O algoritmo primeiro tenta dividir por parágrafos duplos, depois por quebras de linha simples, depois por espaços, e só em último caso faz cortes arbitrários. Isso preserva a estrutura semântica do texto original.

O `chunk_overlap` é crucial para não perder contexto nas bordas. Se uma informação importante está no final de um chunk e é referenciada no início do próximo, o overlap garante que essa conexão seja mantida em pelo menos um dos chunks.

## Re-ranking: o filtro de qualidade

Se chunking é a fundação, re-ranking é o controle de qualidade que garante que só o melhor material chegue ao LLM. E isso é mais importante do que parece.

Quando você faz uma busca vetorial, o sistema retorna os N documentos mais similares baseado em distância cosine ou outra métrica. Mas aqui está o problema: a similaridade de embedding é apenas uma aproximação grosseira de relevância real. O processo de converter texto em vetores inevitavelmente perde informação, e dois textos podem ter embeddings similares sem serem realmente relevantes para a query específica.

É aí que entra o re-ranking. Depois de recuperar um conjunto inicial amplo de candidatos, digamos 10 ou 20 chunks, um modelo especializado reavalia cada um deles em relação à query original e atribui um score de relevância refinado. Os chunks são então reordenados baseado nesses novos scores, e apenas os melhores, talvez 3 ou 4, são passados para o LLM.

A técnica mais comum para re-ranking usa **Cross-Encoders**. Diferente dos bi-encoders usados para criar embeddings, que processam query e documento separadamente, cross-encoders processam ambos juntos. Isso permite uma análise muito mais profunda da relação entre a pergunta e o conteúdo, resultando em scores de relevância muito mais precisos.

O trade-off é que cross-encoders são mais lentos porque precisam processar cada par query-documento individualmente. Por isso usamos em duas etapas: primeiro uma busca vetorial rápida para pegar muitos candidatos, depois re-ranking mais lento mas preciso para filtrar os melhores.

Veja como implementar isso na prática:

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

O modelo `cross-encoder/ms-marco-MiniLM-L-6-v2` é uma escolha sólida para começar. É relativamente pequeno e rápido, mas ainda oferece uma melhoria significativa sobre confiar apenas nos scores de similaridade vetorial.

## Juntando tudo

Agora vamos ver como todos esses componentes se conectam em um pipeline RAG completo e funcional:

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

Esse código representa um sistema RAG robusto que vai muito além do básico. Você tem chunking inteligente que preserva contexto semântico, retrieval que busca candidatos amplos, re-ranking que filtra apenas os melhores, e generation que força o modelo a se basear no contexto fornecido.

## Ou seja

Dominar RAG é essencial para qualquer AI Engineer que quer construir sistemas de produção sérios. Não é mais sobre escrever prompts bonitos, é sobre arquitetar pipelines que garantem qualidade consistente e confiável.

As técnicas que exploramos aqui, especialmente chunking avançado e re-ranking, são o tipo de conhecimento que separa implementações amadoras de sistemas enterprise-grade. E o melhor é que frameworks como LangChain tornam a implementação acessível, permitindo que você foque na arquitetura e na otimização ao invés de reinventar a roda.

O próximo passo natural é explorar técnicas ainda mais avançadas como Agentic RAG, onde o sistema decide autonomamente quando e como buscar informação, e GraphRAG para casos que exigem raciocínio sobre relacionamentos complexos. Mas com a fundação que construímos aqui, você já está preparado para entregar resultados que realmente impressionam.

A jornada de prompt engineering para Context Engineering é uma evolução necessária. E agora você tem as ferramentas para fazer essa transição.
