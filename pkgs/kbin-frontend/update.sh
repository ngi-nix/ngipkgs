#! /usr/bin/env -S nix shell nixpkgs#curl nixpkgs#jq --command bash

if [ $# != 1 ]
then
	echo "Exactly two arguments expected:"
	echo " - Version of /kbin."
	echo " - Hash of the commit for which \`package.json\` should be fetched."
	echo ""
	echo "Example:"
	echo "         $0 0.0.1 a81a6e15cbf27a23d7cd47e5889c8fe4f00f3eaa"
	exit 1
fi

curl "https://codeberg.org/Kbin/kbin-core/raw/commit/$1/package.json" \
| jq '. *= {name: "kbin-frontend", version: "0.0.1", license: "AGPL-3.0-or-later"}' \
> package.json
