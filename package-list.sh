#! /usr/bin/env bash
IT=.
PACKAGES=$(nix flake show --json $IT | jq -r '.packages."x86_64-linux" | keys[] | select(endswith("toplevel") | not)')
(for PACKAGE in $PACKAGES
do
jq -n \
  --arg name $PACKAGE \
  --slurpfile meta <(nix eval --json .#${PACKAGE}.meta) \
  --slurpfile drv <(nix derivation show .#${PACKAGE}) \
  '($drv[0] | to_entries | .[] | .value | { Name: "[`\($name)`](\($meta[0].position | ltrimstr("/nix/store/") | .[index("/"):index(":")]))", Website: ($meta[0].homepage | if . then "[link](\($meta[0].homepage))" else "" end), Version: .env.version }) *
   ($meta[0] | {
	Description: (.description // ""),
	License: (.license | if type == "array" then map(.spdxId) else (.spdxId // "") end),
  })'

done) | jq -s '.' | tv --style markdown