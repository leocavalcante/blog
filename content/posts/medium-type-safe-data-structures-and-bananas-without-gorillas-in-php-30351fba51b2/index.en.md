---
title: Type-safe data structures and bananas without gorillas in PHP
description: I used to love everything about object oriented programming, ignoring everything else, when I finally got it, I thought that every piece of software should be developed using OO...
date: "2017-04-30T17:23:50-03:00"
updated: "2017-04-30T17:23:50-03:00"
draft: false
tags:
    - php
    - functional-programming
    - type-safety
    - programming
    - best-practices
url: /en/archive/medium/type-safe-data-structures-and-bananas-without-gorillas-in-php-30351fba51b2/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

I used to love everything about object oriented programming, ignoring everything else, when I finally got it, I thought that every piece of software should be developed using OO and if it is not, it is wrong.

Meanwhile, I was very happy studying JavaScript, then I got hit by this **Functional Programming** thing. The first common thought was: _is it programming with functions?_ Yes and **no**. Found out that it is about functions, but it shouldn’t be imperative code inside functions, it is way beyond. Anyway, this isn’t about it, but studying FP and Functional Languages I discovered that **OO isn’t a bullet-proof concept, it has some failures**.

_Design patterns, SOLID, GRASP etc, are principles in OO to solve problems that OO itself causes, not to essentially make it better._

Joining those Functional Programming ideas and some things I learned from JavaScript community, crossed my mind some code to show.

But first, a PHP problem. It lacks type-safe data structures. You can’t strictly set types to properties, one way to solve it is to define getters and setters. I’m going to use a reduced version of a getter/setter in the examples to ensure type safety.

Let’s imagine that we have a Swimmer with a name and a wetsuit:

<a href="https://medium.com/media/c041644022078c8ba3e8a64e08313245/href">https://medium.com/media/c041644022078c8ba3e8a64e08313245/href</a>

Cool! name and wetsuit are strictly Strings. Can’t be any other thing. If they are public properties we could set Integers to them. And our $swimmer can swim().

<a href="https://medium.com/media/603a7f9fca1d6a620a51abe3947b5db1/href">https://medium.com/media/603a7f9fca1d6a620a51abe3947b5db1/href</a>

Ok, let’s dive into an OO problem. Imagine that now we have a Cyclist, but who can also swim(), like we see in triathlon competitions.

![](cover.jpg)

Love old memes<a href="https://medium.com/media/f2cd9cabae1bf0e710b737f674957225/href">https://medium.com/media/f2cd9cabae1bf0e710b737f674957225/href</a>

Easy!

<a href="https://medium.com/media/1d31cc7a64edbe9cb25391d9089cb9a3/href">https://medium.com/media/1d31cc7a64edbe9cb25391d9089cb9a3/href</a>

#### What now?

Well, imagine that now we want a simple Cyclist, who doesn’t swim(). How to accomplish it? Extract swim() to a Trait? SwimmerInterface? Cyclist and SwimmerCyclist? What if we need a Runner for a complete Triathlete? SwimmerCyclistRunner? A Triathlete who implements Interfaces and use Traits? Then classes will be only type declarations and implementations will be divided into Traits? How to test all this? **OMG!**

> The problem with object-oriented languages is they’ve got all this implicit environment that they carry around with them. You wanted a banana but what you got was a gorilla holding the banana and the entire jungle. — Joe Armstrong

> If you have referentially transparent code, if you have pure functions all the data comes in its input arguments and everything goes out and leave no state behind it’s incredibly reusable. — Joe Armstrong

### Pure functions

What if we split behavior from data into pure functions? swim(), ride() and run() as pure functions expecting exactly what they need to be called successfully?

First, let’s define our type-safe data structures using interfaces:

<a href="https://medium.com/media/661745b3c769099257804b8c1d4cbc05/href">https://medium.com/media/661745b3c769099257804b8c1d4cbc05/href</a>

And the implementations that we’ll be suffixing with Type:

<a href="https://medium.com/media/e7a14e1c180ad00db0cf6ab65303f63f/href">https://medium.com/media/e7a14e1c180ad00db0cf6ab65303f63f/href</a>

Note that this is only to accomplish type-safe data structures. All this boilerplate could be avoided by RFCs like [Typed Properties](https://wiki.php.net/rfc/typed-properties) and [Property Type Hint](https://wiki.php.net/rfc/property_type_hints).

But let’s keeping going and add our **pure functions** for each behavior:

<a href="https://medium.com/media/d00035d3ad8f5bd2d078303c2e132342/href">https://medium.com/media/d00035d3ad8f5bd2d078303c2e132342/href</a>

And at least, the proof of concept, the Triathlete:

<a href="https://medium.com/media/3f5e0bf761da03b2e6e82914bb60ff2a/href">https://medium.com/media/3f5e0bf761da03b2e6e82914bb60ff2a/href</a>

Now we can have all kinds of behavior reusability, everyone can swim() if it’s a Swimmer, everyone can ride() if it’s a Cyclist and everyone can run() if it’s a Runner. And Triathlete is all three and it can use the exact same behavior of them.

<a href="https://medium.com/media/28bf7cd80699c6aeace7c74a209cca91/href">https://medium.com/media/28bf7cd80699c6aeace7c74a209cca91/href</a>

What you think? Have you already some thoughts on this approach? There are some drawbacks of splitting data and behavior? **Leave some comments below.**

_P.S.: I know, it is a lot of boilerplate code to ensure type safety._
