#! /usr/bin/env -S nix shell nixpkgs#yarn nixpkgs#git nixpkgs#php82Packages.composer --command bash

set -eu

KBIN_ROOT=$(mktemp -d kbin-core.XXX)

git clone https://codeberg.org/Kbin/kbin-core.git $KBIN_ROOT

if [ ! -f "$KBIN_ROOT/.env" ]
then
	ln $KBIN_ROOT/.env.example $KBIN_ROOT/.env
fi

composer --ignore-platform-req=ext-amqp --ignore-platform-req=ext-redis \
  install --working-dir=$KBIN_ROOT

yarn --cwd=$KBIN_ROOT install
yarn --cwd=$KBIN_ROOT build