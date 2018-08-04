---
title: 'Tutorial: Handling State in Flutter with ReduRx.'
description: One the of the hardest things in development - IMHO - after naming, is handling State, at least handling it reactively without overs (over-building, over-rendering, over-paintin...
date: "2018-08-04T15:29:51-03:00"
updated: "2018-08-30T11:31:59-03:00"
draft: false
tags:
    - android-app-development
    - dart
    - flutter
    - ios-app-development
    - redux
url: /en/archive/medium/tutorial-handling-state-in-flutter-with-redurx-b4d50c647e4a/
cover: cover.gif
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

One the of the hardest things in development - IMHO - after naming, is handling State, at least handling it reactively without overs (over-building, over-rendering, over-painting and overhead!).

### Let’s get started!

No secret:

```
flutter create geo_tag_diary
```

Open it in your favorite editor, I personally like VSCode, so code geo\_tag\_diary, then add flutter\_redurx in your dependencies key at pubspec.yaml. Let you editor get the dependencies again or run in the project folder: flutter packages get.

```
dependencies:
  flutter_redurx:
  flutter:
    sdk: flutter
```

Now let’s create a very basic app just to see it working in the device/emulator/simulator (you name it).

Create a lib/app.dart file and add the contents:

<a href="https://medium.com/media/1bf812c62600169ed1da9298d6702138/href">https://medium.com/media/1bf812c62600169ed1da9298d6702138/href</a>

And replace everything at lib/main.dart by:

<a href="https://medium.com/media/63287de8590c60d120a70e5c383fe3f6/href">https://medium.com/media/63287de8590c60d120a70e5c383fe3f6/href</a>

Run the app, you should be seeing It works on the center of the screen. And you know what this means, it means **our greenfield is working!**

### Adding Flutter-ReduRx

Let’s change it a little bit so we can see some Flutter-ReduRx magic happening.

First, we create the class that will represent our State, I’ll call it Diary and place it at lib/diary.dart:

<a href="https://medium.com/media/c63e663d38c683d481a0d1a27ba7b8e3/href">https://medium.com/media/c63e663d38c683d481a0d1a27ba7b8e3/href</a>

Then we change lib/main.dart to create the initial State, give it to a Store and give the Store to a Provider:

<a href="https://medium.com/media/9ef4ddcb333cb22ca70cde3b6650f2e1/href">https://medium.com/media/9ef4ddcb333cb22ca70cde3b6650f2e1/href</a>

Flutter-ReduRx is a companion between Flutter’s bindings (Provider & Connect) and [ReduRx](https://github.com/leocavalcante/ReduRx) state management (thought Store & Action).

Let’s see what this Connect means in the newlib/app.dart. **Please, read the comments on the code:**

<a href="https://medium.com/media/c1510dcf39e1dda52b05abac3ef9567a/href">https://medium.com/media/c1510dcf39e1dda52b05abac3ef9567a/href</a>

> Right, but all of this could just be replaced by the new message on the greenfield version…

We are going to see **the why** now!

### Mutating the State with Actions

Actions are the last concept here and will close de Flux model.

Let’s create an Action that mutates our previous initial State by a new message. At lib/actions.dart:

<a href="https://medium.com/media/3e4aa7a8108ed4405b2ded981ee2cbb3/href">https://medium.com/media/3e4aa7a8108ed4405b2ded981ee2cbb3/href</a>

To **dispatch** this Actions we can call dispatch method on the Store. Pay attention to the comments again, please.

And note that we changed lib/app.dart to handle more components on a Column.

<a href="https://medium.com/media/dd7155b7979e9cb53629bce2e0cb0edb/href">https://medium.com/media/dd7155b7979e9cb53629bce2e0cb0edb/href</a>

> Pretty cool! But life isn’t made about hard-coded constants. We talk to databases, another applications and services in general…

### Here comes AsyncActions

Just like Actions, but with the power of Dart’s Async constructs.

Let’s improve our Diary with cool random quotes to make your day greater. I’ll be using [Tadas Talaikis](https://medium.com/u/58ac2a3f4f56) API (no good reason, just Googled about “free quote api”) and HTTP abstraction from [http package](https://pub.dartlang.org/packages/http). The lib/actions.dart should look like:

<a href="https://medium.com/media/728af8b3676bebffba9b15f3556bc202/href">https://medium.com/media/728af8b3676bebffba9b15f3556bc202/href</a>

We should update lib/app.dart to call our newly created AsyncAction. As always, please continue the read by taking a look at the comments on the code:

<a href="https://medium.com/media/ec613b36f6cb0295c4a9e9bfa47944ca/href">https://medium.com/media/ec613b36f6cb0295c4a9e9bfa47944ca/href</a>

### The result

[https://github.com/leocavalcante/Flutter-ReduRx-GeoTagDiary/tree/part-1](https://github.com/leocavalcante/Flutter-ReduRx-GeoTagDiary/tree/part-1)

![](cover.gif)

Why this is called “GeoTagDiary” and there is a “part 1”? Because one single String is easy, there is more to come! Stay tuned!

Thanks!

The [**Flutter Pub**](https://medium.com/FlutterPub) is a medium publication to bring you the latest and amazing resources such as articles, videos, codes, podcasts etc. about this great technology to teach you how to build beautiful apps with it. You can find us on [Facebook](https://www.facebook.com/FlutterPub), [Twitter](https://twitter.com/FlutterPub), and [Medium](https://medium.com/flutterpub) or learn more about us [here](https://medium.com/flutterpub/welcome-to-flutter-pub-8480678ed212). We’d love to connect! And if you are a writer interested in writing for us, then you can do so [through these guidelines](https://medium.com/flutterpub/how-to-submit-your-article-s-on-flutterpub-7b6bf37dfc43).

![](media/image-01.jpg)
