#! /usr/bin/env -S nix shell nixpkgs#yarn nixpkgs#git nixpkgs#php82Packages.composer --command bash

set -eu

# This is the shasum of a `yarn.lock` file without any entries.
# It is not the same as the hash of the emtpy file, because
# `yarn` will always put a header and some new lines at the
# top of `yarn.lock`, even if no actual entries follow.
# we use it to test whether a `yarn.lock` is effectively empty.
YARN_LOCK_EMPTY="b7345d9afeb53367b66448d477782bb77dc8bf59"

KBIN_ROOT=$(mktemp -d kbin-core.XXX)

#if [ ! -d "$KBIN_ROOT" ]
#then
	git clone https://codeberg.org/Kbin/kbin-core.git $KBIN_ROOT
#fi

cp -v $KBIN_ROOT/yarn.lock yarn.lock

if [ ! -f "$KBIN_ROOT/.env" ]
then
	ln $KBIN_ROOT/.env.example $KBIN_ROOT/.env
fi

composer --ignore-platform-req=ext-amqp --ignore-platform-req=ext-redis \
  install --working-dir=$KBIN_ROOT

for DIR in $(jq -r '.devDependencies | to_entries | .[].value | select(startswith("file:")) | ltrimstr("file:")' < $KBIN_ROOT/package.json)
do
        yarn --cwd=$KBIN_ROOT/$DIR install

	if [ "$(cat $KBIN_ROOT/$DIR/yarn.lock | shasum | cut -f1 -d' ')" = "$YARN_LOCK_EMPTY" ]
	then
		continue
	fi

	echo "# BEGIN ADDITIONS FOR $DIR" >> yarn.lock
	tail -n +5 $KBIN_ROOT/$DIR/yarn.lock >> yarn.lock
	echo "# END ADDITIONS FOR $DIR" >> yarn.lock
done

# Workaround until <https://github.com/NixOS/nixpkgs/pull/257337> is merged.
sed -i 's/"\@\(.*\)@file:/"_\1@file:/g' yarn.lock