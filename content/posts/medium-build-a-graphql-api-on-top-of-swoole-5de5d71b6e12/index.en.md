---
title: Build a GraphQL API on top of Swoole
description: I’m assuming you already know what is GraphQL and Swoole, so what about getting started right straight to the code, shall we?
date: "2019-08-10T16:24:14-03:00"
updated: "2019-08-10T16:53:06-03:00"
draft: false
tags:
    - api
    - graphql
    - siler
    - swoole
url: /en/archive/medium/build-a-graphql-api-on-top-of-swoole-5de5d71b6e12/
cover: ""
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

I’m assuming you already know what is [GraphQL](https://graphql.org/) and [Swoole](https://www.swoole.co.uk), so what about getting started right straight to the code, shall we?

What you maybe doesn’t know yet is about [Siler](https://github.com/leocavalcante/siler)! It is a set of general purpose high-level abstractions aiming an API for declarative programming in PHP.

With [Siler](https://github.com/leocavalcante/siler) we can abstract way “hard” parts from popular tools like GraphQL and recently Swoole. And yes, I’m the author, so feel free to file any issues or make any questions about it.

**“Talk is cheap, show me the code”. Let’s go!**

I want to make it simple as possible so we can focus on using GraphQL and Swoole through Siler instead of solving hard domain and business logic problems, so we are going to implement a gold-old to-do list.

```
$ mkdir todos
$ cd todos/
```

Don’t know about you, but I really like to start a project from a clean greenfield instead of using boilerplate/skeleton code.

```
$ composer require leocavalcante/siler
$ composer require webonyx/graphql-php
$ composer require --dev swoole/ide-helper
```

That is our deps. Siler itself doesn’t re-implements a GraphQL parser/executor, it builds on top of the Webonyx’s current work, same for Swoole, of course, so make sure you have Swoole extension up-n-running on your PHP environment.

### The schema

A Todo is simple, we need a ID to uniquely identify it, a title to work as a short description, a body to work as a full description and a flag to tell if it is already done.

<a href="https://medium.com/media/2e88bfd9a29510097ef679b0a71f49ba/href">https://medium.com/media/2e88bfd9a29510097ef679b0a71f49ba/href</a>

We also need a type to work as an Input and of couse, if you know GraphQL, a Query type to query Todos and a Mutation type to create, change and delete them. Here is our full schema:

<a href="https://medium.com/media/26b96d722cec48bc9aa61fd9ae544465/href">https://medium.com/media/26b96d722cec48bc9aa61fd9ae544465/href</a>

That is it! Let’s go to PHP then.

### The server

Again, assuming you already know, but… using Swoole we build our own HTTP server, just like Node.js, it’s a good, shall we?

<a href="https://medium.com/media/be55c26f415cf5ff2ca4f00d8886d0cc/href">https://medium.com/media/be55c26f415cf5ff2ca4f00d8886d0cc/href</a>

You probably saw something different at Swoole’s documentation. **That is Siler working!** Making it even more simple and enjoyable. Just like regular PHP functions, but borrowing pureness, immutability and high-order as much as possible from the Functional Programming paradigm.

Start the server using php index.php head to [http://localhost:8000](http://localhost:8000) (or whatever port you override using the PORT environment variable) and check if it’s working.

### The domain

Now it’s time work on our domain.

First we define our Todos module. It’s the module that will hold the functions that work on a Todo. I know, it’s not Object Oriented-ish, but I really don’t care, I don’t want to. We can work on this using whatever paradigm you like, you will see that it’s not coupled to rest of the code.

<a href="https://medium.com/media/4a6af67ad9bf9c50759a627b45ad2a4d/href">https://medium.com/media/4a6af67ad9bf9c50759a627b45ad2a4d/href</a>

For now, that is what we are going to do, find and save. find can receive a Criteria that’s how you can build a lot of different ways to query for a Todo. They are simple:

<a href="https://medium.com/media/e45cbd933bfe6d0c646809484bde3d68/href">https://medium.com/media/e45cbd933bfe6d0c646809484bde3d68/href</a>

The application

I’m not trying to accomplish DDD here, but hey, that’s a cool concept, right? After defining our domain, we are ready to move to the next layer and starting building the application layer. Nothing more clean and useful for testing then an in-memory implementation of some I/O.

<a href="https://medium.com/media/c499d0f0fe5e22551e7060775818b13b/href">https://medium.com/media/c499d0f0fe5e22551e7060775818b13b/href</a>

Very clear what is going on here, right? We are finding and saving on an in-memory array.

Having the Todos interface and working on its implementations opens a wide range of possibilities from testing using in-memory implementations to real work at PDO or NoSQL implementations. You will get assimilate now when you see how Resolvers are built:

### The resolvers

<a href="https://medium.com/media/09ecbbec0ecb5186e18c4ca76a7282a8/href">https://medium.com/media/09ecbbec0ecb5186e18c4ca76a7282a8/href</a>

The Query resolver just basically binds a Criteria to a Todos module. Note that both resolvers depends on the abstraction of a Todos module, not an implementation.

The Save resolver shows a little more about is functionally, maybe you assimilate them to a Controller of the MVC pattern.

Now we need to bring these pieces together in a way that is easy to later tell the Schema builder what resolver it should be using. Well, what about a factory?

<a href="https://medium.com/media/3b939a3f82e95f81564e4f2635a22ac3/href">https://medium.com/media/3b939a3f82e95f81564e4f2635a22ac3/href</a>

### The server (update)

Our source-code is all there, our domain, its implementations and resolvers working as the application. Now is time to glue all this to the server:

<a href="https://medium.com/media/0f0f3bffa0c35181542fd0447f647c86/href">https://medium.com/media/0f0f3bffa0c35181542fd0447f647c86/href</a>

And there is our **GraphQL** API running on top of **Swoole** with the help of **Siler**!

I hope you enjoyed it. Feel free to ask any questions.

[Full source-code is available here.](https://github.com/leocavalcante/swoole-graphql-api)

Thanks!
