#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

usage() {
  cat <<'USAGE'
Usage: scripts/download-bundle.sh

Downloads a git bundle from Google Drive and unbundles it into the local repo.

Defaults:
  DRIVE_FOLDER_NAME LC
  BUNDLE_NAME       blog.bundle
  BUNDLE_PATH       /private/tmp/$BUNDLE_NAME

Optional:
  IMPORT_REF=refs/heads/from-blog-bundle scripts/download-bundle.sh

When IMPORT_REF is set, the script also fetches the bundle's HEAD into that ref.
Without IMPORT_REF, it only verifies and unbundles the objects.
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
bundle_path="${BUNDLE_PATH:-/private/tmp/${bundle_name}}"

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
git bundle unbundle "$bundle_path"

if [[ -n "${IMPORT_REF:-}" ]]; then
  git fetch "$bundle_path" "HEAD:${IMPORT_REF}"
  echo "Imported bundle HEAD into ${IMPORT_REF}"
fi

echo "Downloaded bundle: ${bundle_path}"
echo "Size: ${size}"
[[ -z "$md5" ]] || echo "MD5: ${md5}"
