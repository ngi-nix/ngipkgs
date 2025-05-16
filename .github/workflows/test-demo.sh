#!/usr/bin/env bash

# nix build .#overview
# podman run --privileged \
#   --volume ./result/project/Cryptpad/default.nix:/default.nix \
#   --volume .:/ngipkgs <DISTRO> /bin/bash \
#   -c "bash /ngipkgs/.github/workflows/test-demo.sh <DISTRO>"

set -euo pipefail

DISTRO="$1"
# shellcheck disable=SC2089,2026
NIX_CONFIG='substituters = https://cache.nixos.org/ https://ngi.cachix.org/'$'\n''trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw='
export NIX_CONFIG


echo -e "\n-> Installing Nix ..."
# Debian/Ubuntu
if echo "$DISTRO" | grep --quiet "debian\|ubuntu"; then
    apt update
    apt install --yes curl git jq nix
# Archlinux
elif echo "$DISTRO" | grep --quiet archlinux; then
    pacman --sync --refresh --noconfirm curl git jq nix
# Other
else
    echo "ERROR: Unknown distro. Exiting ..."
    exit 1
fi

echo -e "\n-> Nix version ..."
function fver { printf '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"; }
NIX_VERSION=$(fver $(nix --version | grep -oP '([0-9]+\.?)+' | sed  's/\./ /g'))
echo "Nix version: $NIX_VERSION"

echo -e "\n-> Building VM ..."
# Nix versions < 2.24 don't work for our use case due to regression in
# closureInfo.
# https://github.com/NixOS/nix/issues/6820
if [ "$NIX_VERSION" -ge 22400 ]; then
    echo "Using Nix installed by Linux package manager"
    nix-build --arg ngipkgs "import /ngipkgs {}" /default.nix
else
    echo "Using Nix from Nixpkgs unstable"

    nixpkgs_revision=$(
        nix-instantiate --eval --attr sources.nixpkgs.rev /ngipkgs \
        | jq --raw-output
    )
    NIXPKGS="https://github.com/NixOS/nixpkgs/archive/$nixpkgs_revision.tar.gz"

    nix-shell \
        --include nixpkgs="$NIXPKGS" \
        --packages nix \
        --run "nix-build --arg ngipkgs \"import /ngipkgs {}\" /default.nix"
fi

echo -e "\n-> Launching VM ..."
./result &

echo -e "\n-> Running test ..."
curl --retry 10 --retry-all-errors --fail localhost:9000 | grep CryptPad
