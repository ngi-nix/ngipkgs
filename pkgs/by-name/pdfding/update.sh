#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-update gitMinimal prefetch-npm-deps coreutils

set -x
set -eou pipefail

version=$(curl ${GITHUB_TOKEN:+ -H "Authorization: Bearer $GITHUB_TOKEN"} -sL https://api.github.com/repos/mrmn2/PdfDing/releases/latest | jq -r '.tag_name')

set +ue
if [[ "v$UPDATE_NIX_OLD_VERSION" == "$version" ]]; then
  echo "Already up-to-date, version: $version"
  exit 0
fi
set -ue

# source hashes
nix-update --version="$version" pdfding
nix-update --version="$version" pdfding.frontend

ROOT_DIR=$(git rev-parse --show-toplevel)

# get relative path from /nix/store to the script
if [[ "$0" == /nix/store/* ]]; then
  # get the path after the hash "pkgs/by-name/pdfding"
  SCRIPT_PATH="${0#/nix/store/*/}"
  PACKAGE_DIR="$ROOT_DIR/$(dirname "$SCRIPT_PATH")"
else
  PACKAGE_DIR="$(realpath "$(dirname "$0")")"
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"

src="$(nix-build --no-link "$ROOT_DIR" -A pdfding.src)"
cp "$src"/{package.json,package-lock.json} .

# npmDeps hash
prev_npm_hash="$(
  nix-instantiate "$ROOT_DIR" \
    --eval --json \
    -A pdfding.frontend.npmDeps.hash |
    jq -r .
)"
new_npm_hash="$(prefetch-npm-deps ./package-lock.json)"

sed -i "s|$prev_npm_hash|$new_npm_hash|g" "$PACKAGE_DIR/frontend.nix"

# pdfjs version
pdfjs_version="$(grep 'PDFJS_VERSION=' "$src/Dockerfile" | cut -d'=' -f2)"

sed -i "s|pdfjsVersion = .*;|pdfjsVersion = \"$pdfjs_version\";|" "$PACKAGE_DIR/frontend.nix"

# pdfjs hash
sed -i "s|pdfjsHash = .*;|pdfjsHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";|" "$PACKAGE_DIR/frontend.nix"

set +e
new_pdfjs_hash="$(
  nix-build --no-out-link -A pdfding.frontend.pdfjs "$ROOT_DIR" 2>&1 >/dev/null | grep "got:" | cut -d':' -f2 | sed 's| ||g'
)"
set -e

sed -i "s|\"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\"|\"$new_pdfjs_hash\"|g" "$PACKAGE_DIR/frontend.nix"
