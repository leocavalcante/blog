#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

posts_dir="content/posts"
moved=0

for bundle in "${posts_dir}"/*/; do
  slug="$(basename "$bundle")"

  # Skip section index files (not page bundles)
  [[ "$slug" == _* ]] && continue

  index="${bundle}index.md"
  if [[ ! -f "$index" ]]; then
    echo "SKIP (no index.md): $slug"
    continue
  fi

  # Extract the date value from frontmatter
  raw_date="$(grep -m1 '^date:' "$index" | sed 's/^date: *//' | tr -d '"')"
  if [[ -z "$raw_date" ]]; then
    echo "SKIP (no date): $slug"
    continue
  fi

  year="${raw_date:0:4}"
  month="${raw_date:5:2}"

  target_dir="${posts_dir}/${year}/${month}"
  mkdir -p "$target_dir"
  git mv "$bundle" "${target_dir}/${slug}"
  echo "MOVED: $slug -> ${year}/${month}/${slug}"
  moved=$((moved + 1))
done

echo ""
echo "Done. Moved $moved post(s)."
