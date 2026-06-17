---
title: What is semantic versioning?
description: Semantic versioning, also called **SemVer**, is a standard used by developers to number software versions clearly and predictably. It makes it easier to understand...
date: "2024-10-24T10:01:27-03:00"
updated: ""
draft: false
tags:
    - semantic-versioning
    - version-control
    - git
    - releases
    - best-practices
url: /en/semver/
cover: cover.jpg
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

Semantic versioning, also called **SemVer**, is a standard used by developers to number software versions clearly and predictably. It makes it easier to understand which changes happened in the software and what impact those changes have. Basically, SemVer uses a three-number notation in the format **X.Y.Z**, where each number has a specific meaning.

## SemVer structure

The structure of semantic versioning is made up of three parts:

1. **X (Major)**: Major version. This number changes when there are changes that break compatibility with previous versions (that is, changes that affect expected behavior). Examples include API changes that may require other developers to modify their code.

2. **Y (Minor)**: Minor version. This number is incremented when new features are added, but they are compatible with previous versions. For example, new features or improvements that do not affect existing behavior.

3. **Z (Patch)**: Bug fixes. This number is used for updates that fix problems or errors without adding new features or breaking compatibility with previous versions.


For example, if you have version **1.4.2**:

* **1** indicates a major version,

* **4** indicates that four sets of new features have been added,

* **2** indicates that there have been two bug fixes since the last change.


## Why use semantic versioning?

SemVer makes software version management much easier, especially when the code is used by other people (such as libraries or APIs). It makes clear when an update will require changes in the code of whoever is using the software, or when it is safe to update without concern. Here are some benefits:

* **Transparency**: Clearly know the type of change (bug fix, feature, or breaking compatibility).

* **Ease of updating**: Users of the software know whether the update will require changes to their own code.

* **Collaboration**: When several people work on the same project, versioning helps organize contributions.


## How to apply semantic versioning?

To use SemVer correctly, follow these guidelines:

1. **Start with version 1.0.0** when the software is released publicly. Versions below that, such as 0.x.x, are for experimental or testing phases, where there are no stability guarantees.

2. **Change the Major number** (X) if the changes are not compatible with previous versions.

3. **Change the Minor number** (Y) if you add new features while maintaining compatibility.

4. **Change the Patch number** (Z) when fixing bugs or smaller issues.


## Practical example

Let's say you released an API at version **2.3.1**. If you fix a small bug, the new version will be **2.3.2**. Now, if you add a new feature without breaking compatibility, it would be **2.4.0**. In the case of a major change that alters how the API works, such as removing or changing endpoints, you would have **3.0.0**.

## Conclusion

Semantic versioning is essential for keeping projects organized and making life easier both for developers who maintain the software and for those who use it. It creates a common language so everyone can quickly understand the impact of an update and help avoid unwanted surprises.

If you want to know more details, check out the [official SemVer site](https://semver.org/).
