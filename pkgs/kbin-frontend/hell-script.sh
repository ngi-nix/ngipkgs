#!/usr/bin/env bash

set -x


while IFS="\n\n" read block
do
    if grep -qv resolved <<< $block > /dev/null; then
	echo $block
    fi
done < yarn.lock
