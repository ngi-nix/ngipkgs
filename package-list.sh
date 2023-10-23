#! /usr/bin/env -S nix shell nixpkgs#moreutils nixpkgs#jq --command bash

set -xeuo pipefail

IT=.

nix flake show --json $IT | jq -r '.packages."x86_64-linux" | keys[]' \
	| grep -v 'toplevel' \
	| tee package-list.txt

mapfile -t < package-list.txt

echo "$MAPFILE"

echo ${MAPFILE[@]/#/${IT}#}
echo NE

nix derivation show ${MAPFILE[@]/#/${IT}#} | tee derivations.json

jq 'to_entries | .[] | { "\(.value.env.pname)": { "drvPath": "\(.key)", "drv": .value } }' < derivations.json | sponge derivations.json

for PACKAGE in "${MAPFILE[@]}"
do
	nix eval --json ${IT}\#${PACKAGE}.meta | jq "{ \"$PACKAGE\": { \"meta\": . } }" | tee meta.json
done

jq -f data.jq -n > data.json
