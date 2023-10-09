#! /usr/bin/env -S nix shell nixpkgs#moreutils nixpkgs#jq --command bash

set -xeuo pipefail

IT=.
DIR=plist

mkdir -p $DIR

if [ ! -f $DIR/packages ]
then
	nix flake show --json $IT | jq -r '.packages."x86_64-linux" | keys[]' \
		| grep -v 'toplevel' \
		| tee $DIR/packages
fi

mapfile -t < $DIR/packages

if [ ! -f $DIR/derivations.json ]
then
	nix derivation show ${MAPFILE[@]/#/${IT}#} | tee $DIR/derivations.json | jq
fi

jq 'to_entries | .[] | { "\(.value.env.pname)": { "drvPath": "\(.key)", "drv": .value } }' < $DIR/derivations.json | sponge $DIR/derivations.json

for PACKAGE in "${MAPFILE[@]}"
do
	nix eval --json ${IT}\#${PACKAGE}.meta | jq "{ \"$PACKAGE\": { \"meta\": . } }" >> $DIR/meta.json
done

jq -s '.[0] * .[1]' $DIR/meta.json $DIR/derivations.json \
  > data.json

exit 0

(for PACKAGE in cat $DIR/packages
do
jq -n \
  --arg name $PACKAGE \
  --slurpfile meta <(nix eval --json ${IT}\#${PACKAGE}.meta) \
  --slurpfile drv <(nix derivation show ${IT}\#${PACKAGE}) \
  '($drv[0] | to_entries | .[] | .value | { Name: "[`\($name)`](\($meta[0].position | ltrimstr("/nix/store/") | .[index("/"):index(":")]))", Website: ($meta[0].homepage | if . then "[link](\($meta[0].homepage))" else "" end), Version: .env.version }) *
   ($meta[0] | {
    Description: (.description // ""),
    License: (.license | if type == "array" then map(.spdxId) else (.spdxId // "") end),
  })'

done) | jq -s '.' | tv --style markdown
