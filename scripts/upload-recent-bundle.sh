#!/usr/bin/env bash
set -euo pipefail

invocation_dir="$(pwd)"
cd "$(git rev-parse --show-toplevel)"

usage() {
  cat <<'USAGE'
Usage: scripts/upload-recent-bundle.sh [commit-count|commit-range]

Creates a git bundle for recent commits and uploads it to Google Drive.

Defaults:
  commit-range      $BASE_REF..HEAD
  BASE_REF          origin/main
  DRIVE_FOLDER_NAME LC
  BUNDLE_NAME       blog.bundle
  BUNDLE_PATH       $PWD/$BUNDLE_NAME
  CLEANUP_ARTIFACTS 1

Examples:
  scripts/upload-recent-bundle.sh
  scripts/upload-recent-bundle.sh 3
  scripts/upload-recent-bundle.sh origin/main..HEAD

With no argument, bundles every commit reachable from HEAD that is not in
origin/main. Set BASE_REF to compare against another branch.
Set ALLOW_DIRTY=1 to bundle commits even when the working tree has local changes.
Set CLEANUP_ARTIFACTS=0 to keep local *.bundle and zoneinfo* files.
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

drive_query_escape() {
  printf '%s' "$1" | sed "s/'/\\\\'/g"
}

json_param() {
  jq -cn "$@"
}

local_md5() {
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$1"
  elif command -v md5sum >/dev/null 2>&1; then
    md5sum "$1" | awk '{print $1}'
  else
    echo ""
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require git
require gws
require jq

folder_name="${DRIVE_FOLDER_NAME:-LC}"
bundle_name="${BUNDLE_NAME:-blog.bundle}"
bundle_path="${BUNDLE_PATH:-${invocation_dir}/${bundle_name}}"
base_ref="${BASE_REF:-origin/main}"
commit_spec="${1:-}"
cleanup_artifacts="${CLEANUP_ARTIFACTS:-1}"

cleanup_generated_artifacts() {
  [[ "$cleanup_artifacts" == "1" ]] || return 0

  local nullglob_was_set=0
  shopt -q nullglob || nullglob_was_set=1
  shopt -s nullglob

  local artifact
  for artifact in "${invocation_dir}"/*.bundle "${invocation_dir}"/zoneinfo*; do
    [[ -f "$artifact" ]] && rm -f -- "$artifact"
  done

  [[ "$nullglob_was_set" -eq 0 ]] || shopt -u nullglob
}

if [[ "${ALLOW_DIRTY:-0}" != "1" ]]; then
  git diff --quiet --ignore-submodules -- || die "working tree has unstaged changes; commit/stash them or set ALLOW_DIRTY=1"
  git diff --cached --quiet --ignore-submodules -- || die "working tree has staged changes; commit/stash them or set ALLOW_DIRTY=1"
fi

if [[ -z "$commit_spec" ]]; then
  git rev-parse --verify --quiet "${base_ref}^{commit}" >/dev/null || die "base ref not found: $base_ref"
  commit_range="${base_ref}..HEAD"
elif [[ "$commit_spec" =~ ^[0-9]+$ ]]; then
  [[ "$commit_spec" -gt 0 ]] || die "commit-count must be greater than zero"
  commit_range="HEAD~${commit_spec}..HEAD"
else
  commit_range="$commit_spec"
fi

commit_count="$(git rev-list --count "$commit_range")"
[[ "$commit_count" -gt 0 ]] || die "commit range produced no commits: $commit_range"

mkdir -p "$(dirname "$bundle_path")"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/blog-bundle-upload.XXXXXX")"
cleanup() {
  rm -rf "$tmp_dir"
  cleanup_generated_artifacts
}
trap cleanup EXIT
tmp_bundle="${tmp_dir}/${bundle_name}"

git bundle create "$tmp_bundle" "$commit_range" >/dev/null
git bundle verify "$tmp_bundle" >/dev/null
mv "$tmp_bundle" "$bundle_path"

folder_query="name='$(drive_query_escape "$folder_name")' and mimeType='application/vnd.google-apps.folder' and trashed=false"
folder_json="$(
  gws drive files list \
    --params "$(json_param --arg q "$folder_query" '{q:$q, fields:"files(id,name,parents,driveId)", pageSize:10, supportsAllDrives:true, includeItemsFromAllDrives:true}')"
)"
folder_count="$(jq '.files | length' <<<"$folder_json")"
[[ "$folder_count" -eq 1 ]] || die "expected exactly one Drive folder named '$folder_name', found $folder_count"
folder_id="$(jq -r '.files[0].id' <<<"$folder_json")"

file_query="name='$(drive_query_escape "$bundle_name")' and '${folder_id}' in parents and trashed=false"
file_json="$(
  gws drive files list \
    --params "$(json_param --arg q "$file_query" '{q:$q, fields:"files(id,name,size,md5Checksum,parents,webViewLink)", pageSize:10, supportsAllDrives:true, includeItemsFromAllDrives:true}')"
)"
file_count="$(jq '.files | length' <<<"$file_json")"
metadata="$(json_param --arg name "$bundle_name" '{name:$name, mimeType:"application/octet-stream"}')"
fields='id,name,mimeType,size,md5Checksum,parents,webViewLink'

if [[ "$file_count" -eq 0 ]]; then
  result="$(
    gws drive files create \
      --params "$(json_param --arg fields "$fields" '{supportsAllDrives:true, fields:$fields}')" \
      --json "$(json_param --arg name "$bundle_name" --arg parent "$folder_id" '{name:$name, parents:[$parent], mimeType:"application/octet-stream"}')" \
      --upload "$bundle_path"
  )"
elif [[ "$file_count" -eq 1 ]]; then
  file_id="$(jq -r '.files[0].id' <<<"$file_json")"
  result="$(
    gws drive files update \
      --params "$(json_param --arg fileId "$file_id" --arg fields "$fields" '{fileId:$fileId, supportsAllDrives:true, fields:$fields}')" \
      --json "$metadata" \
      --upload "$bundle_path"
  )"
else
  die "expected at most one '$bundle_name' in Drive folder '$folder_name', found $file_count"
fi

remote_size="$(jq -r '.size // empty' <<<"$result")"
remote_md5="$(jq -r '.md5Checksum // empty' <<<"$result")"
size="$(wc -c <"$bundle_path" | tr -d '[:space:]')"
md5="$(local_md5 "$bundle_path")"

[[ -z "$remote_size" || "$remote_size" == "$size" ]] || die "uploaded size mismatch: local=$size remote=$remote_size"
[[ -z "$remote_md5" || -z "$md5" || "$remote_md5" == "$md5" ]] || die "uploaded md5 mismatch: local=$md5 remote=$remote_md5"

echo "Bundled ${commit_count} commit(s): ${commit_range}"
echo "Local bundle: ${bundle_path}"
echo "Drive file: $(jq -r '.webViewLink // .id' <<<"$result")"
echo "Size: ${size}"
[[ -z "$md5" ]] || echo "MD5: ${md5}"
