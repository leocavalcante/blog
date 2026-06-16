#!/usr/bin/env -S uv run --script
"""Preview and apply post tag consolidation rules.

Usage:
  ./scripts/consolidate_tags.py          # dry-run report
  ./scripts/consolidate_tags.py --write  # rewrite matching front matter tags
"""

from __future__ import annotations

import argparse
import re
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
POST_GLOB = "content/posts/**/index*.md"
TAG_INDENT = "    "
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)
TAG_ITEM_RE = re.compile(r"^\s*-\s+(.*?)\s*$")

GROUPS: dict[str, list[str]] = {
    "ai": [
        "ai",
        "artificial-intelligence",
        "artificial-inteligence",
        "ai-engineering",
        "llm",
        "llms",
    ],
    "developer-experience": ["developer-experience", "devex", "dx"],
    "go": ["go", "golang"],
    "agent": ["agent", "agents"],
}

VARIANT_TO_CANONICAL = {
    variant: canonical for canonical, variants in GROUPS.items() for variant in variants
}


def iter_posts() -> list[Path]:
    return sorted(ROOT.glob(POST_GLOB))


def split_frontmatter(text: str) -> tuple[str, str]:
    match = FRONTMATTER_RE.match(text)
    if match is None:
        raise ValueError("missing YAML front matter")
    return match.group(1), text[match.end() :]


def extract_tags(frontmatter: str) -> tuple[list[str], int, int, list[str]]:
    lines = frontmatter.splitlines(keepends=True)
    for start, line in enumerate(lines):
        stripped = line.strip()
        if stripped == "tags: []":
            return [], start, start + 1, lines
        if stripped != "tags:":
            continue

        end = start + 1
        tags: list[str] = []
        while end < len(lines):
            match = TAG_ITEM_RE.match(lines[end])
            if match is None:
                break
            tags.append(match.group(1))
            end += 1
        return tags, start, end, lines

    raise ValueError("missing tags block")


def dedupe(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


def normalize_tags(tags: list[str]) -> list[str]:
    return dedupe([VARIANT_TO_CANONICAL.get(tag, tag) for tag in tags])


def format_tags(tags: list[str]) -> list[str]:
    if not tags:
        return ["tags: []\n"]
    return ["tags:\n", *[f"{TAG_INDENT}- {tag}\n" for tag in tags]]


def rewrite_frontmatter(frontmatter: str) -> tuple[str, list[str], list[str]]:
    current_tags, start, end, lines = extract_tags(frontmatter)
    normalized = normalize_tags(current_tags)
    new_lines = lines[:start] + format_tags(normalized) + lines[end:]
    return "".join(new_lines), current_tags, normalized


def group_report(
    paths: list[Path],
) -> tuple[dict[str, dict[str, int]], dict[str, dict[str, list[str]]]]:
    counts: dict[str, dict[str, int]] = {
        canonical: defaultdict(int) for canonical in GROUPS
    }
    affected: dict[str, dict[str, list[str]]] = {
        canonical: defaultdict(list) for canonical in GROUPS
    }
    for path in paths:
        frontmatter, _ = split_frontmatter(path.read_text())
        tags, *_ = extract_tags(frontmatter)
        normalized = normalize_tags(tags)
        for canonical, variants in GROUPS.items():
            matched = [tag for tag in tags if tag in variants]
            if not matched:
                continue
            for tag in matched:
                counts[canonical][tag] += 1
            if tags != normalized:
                affected[canonical][str(path.relative_to(ROOT))] = matched
    return counts, affected


def print_report(paths: list[Path]) -> None:
    counts, affected = group_report(paths)
    for canonical, variants in GROUPS.items():
        if not counts[canonical]:
            continue
        print(f"[{canonical} -> {canonical}]")
        for variant in variants:
            count = counts[canonical][variant]
            if count:
                print(f"- {variant}: {count}")
        changed_entries = affected[canonical]
        print(f"  affected files: {len(changed_entries)}")
        for rel_path, matched in sorted(changed_entries.items()):
            preview = ", ".join(matched)
            print(f"  {rel_path}: {preview} -> {canonical}")
        print()


def write_changes(paths: list[Path]) -> int:
    changed = 0
    for path in paths:
        original = path.read_text()
        frontmatter, body = split_frontmatter(original)
        rewritten_frontmatter, current_tags, normalized_tags = rewrite_frontmatter(frontmatter)
        if current_tags == normalized_tags:
            continue
        path.write_text(f"---\n{rewritten_frontmatter}\n---\n{body}")
        changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="rewrite files in place")
    args = parser.parse_args()

    paths = iter_posts()
    print_report(paths)
    if not args.write:
        return 0

    changed = write_changes(paths)
    print(f"Updated {changed} files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
