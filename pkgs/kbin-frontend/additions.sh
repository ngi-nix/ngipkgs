#! /usr/bin/env bash

set -xeu

KBIN_ROOT=$1
YARN_LOCKFILES=$2

for DIR in $(jq -r '.devDependencies | to_entries | .[].value | select(startswith("file:")) | ltrimstr("file:")' < $KBIN_ROOT/package.json)
do
        cd $KBIN_ROOT$DIR
	yarn install
	cp yarn.lock $YARN_LOCKFILES/$(echo $DIR | tr '/' '_').lock
done
