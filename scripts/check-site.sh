#!/usr/bin/env bash
set -euo pipefail

HUGO_BIN="${HUGO_BIN:-hugo}"
future_dir="content/posts/__future-publish-check"

cleanup() {
  rm -rf "${future_dir}" public
}
trap cleanup EXIT

mkdir -p "${future_dir}"
cat > "${future_dir}/index.md" <<'POST'
---
title: "Future Publish Check"
description: "Build-time future post check."
date: "2099-01-01T00:00:00-03:00"
updated: ""
draft: false
tags: ["test"]
url: "/__future-publish-check/"
cover: ""
cover_alt: ""
cover_credit_name: ""
cover_credit_url: ""
---

This post should only render when Hugo is called with --buildFuture.
POST

"${HUGO_BIN}" --gc --minify --panicOnWarning
test ! -e public/__future-publish-check/index.html

"${HUGO_BIN}" --gc --minify --panicOnWarning --buildFuture
test -e public/__future-publish-check/index.html
