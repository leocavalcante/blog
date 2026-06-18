#!/usr/bin/env bash
set -euo pipefail

invocation_dir="$(pwd)"
cd "$(git rev-parse --show-toplevel)"

usage() {
  cat <<'USAGE'
Usage: scripts/download-bundle.sh

Downloads a git bundle from Google Drive and fast-forwards the current branch.

Defaults:
  DRIVE_FOLDER_NAME LC
  BUNDLE_NAME       blog.bundle
  BUNDLE_PATH       $PWD/$BUNDLE_NAME
  APPLY_MODE        ff-only
  CLEANUP_ARTIFACTS 1

Optional:
  IMPORT_REF=refs/heads/from-blog-bundle scripts/download-bundle.sh
  APPLY_MODE=none scripts/download-bundle.sh

By default, the script fetches the bundle HEAD and runs git merge --ff-only.
Set IMPORT_REF to fetch the bundle HEAD into that ref instead of updating the
current branch. Set APPLY_MODE=none to only verify and unbundle objects.
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
apply_mode="${APPLY_MODE:-ff-only}"
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

trap cleanup_generated_artifacts EXIT

mkdir -p "$(dirname "$bundle_path")"

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
[[ "$file_count" -eq 1 ]] || die "expected exactly one '$bundle_name' in Drive folder '$folder_name', found $file_count"

file_id="$(jq -r '.files[0].id' <<<"$file_json")"
remote_size="$(jq -r '.files[0].size // empty' <<<"$file_json")"
remote_md5="$(jq -r '.files[0].md5Checksum // empty' <<<"$file_json")"

gws drive files get \
  --params "$(json_param --arg fileId "$file_id" '{fileId:$fileId, alt:"media", supportsAllDrives:true}')" \
  --output "$bundle_path" >/dev/null

size="$(wc -c <"$bundle_path" | tr -d '[:space:]')"
md5="$(local_md5 "$bundle_path")"

[[ -z "$remote_size" || "$remote_size" == "$size" ]] || die "downloaded size mismatch: local=$size remote=$remote_size"
[[ -z "$remote_md5" || -z "$md5" || "$remote_md5" == "$md5" ]] || die "downloaded md5 mismatch: local=$md5 remote=$remote_md5"

git bundle verify "$bundle_path" >/dev/null

case "$apply_mode" in
  ff-only)
    if [[ -n "${IMPORT_REF:-}" ]]; then
      git fetch "$bundle_path" "HEAD:${IMPORT_REF}"
      echo "Imported bundle HEAD into ${IMPORT_REF}"
    else
      current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
      [[ -n "$current_branch" ]] || die "not on a branch; set IMPORT_REF or APPLY_MODE=none"
      git diff --quiet --ignore-submodules -- || die "working tree has unstaged changes; commit/stash them or set APPLY_MODE=none"
      git diff --cached --quiet --ignore-submodules -- || die "working tree has staged changes; commit/stash them or set APPLY_MODE=none"
      git fetch "$bundle_path" HEAD
      git merge --ff-only FETCH_HEAD
      echo "Fast-forwarded ${current_branch} to bundle HEAD"
    fi
    ;;
  none)
    git bundle unbundle "$bundle_path" >/dev/null
    echo "Unbundled objects without updating a ref"
    ;;
  *)
    die "unsupported APPLY_MODE: $apply_mode"
    ;;
esac

echo "Downloaded bundle: ${bundle_path}"
echo "Size: ${size}"
[[ -z "$md5" ]] || echo "MD5: ${md5}"
