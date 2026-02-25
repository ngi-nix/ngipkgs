#!/usr/bin/env bash

set -eo pipefail

_pkg_install() {
    local pkgs=("$@")

    case "$DISTRO" in
    *debian* | *ubuntu*)
        apt update
        apt install --yes "${pkgs[@]}"
        ;;
    *archlinux*)
        pacman -Syu --noconfirm "${pkgs[@]}"
        ;;
    *)
        echo "ERROR: Unknown distro '$DISTRO'. Exiting ..." >&2
        exit 1
        ;;
    esac
}

install_nix() {
    _pkg_install curl

    if [[ "$INSTALLER" != "distro" ]]; then
        curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --no-confirm --init none
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        return
    fi

    _pkg_install jq nix
}

nix_version() {
    function fver { printf '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"; }
    echo $(fver $(nix --version | grep -oP '([0-9]+\.?)+' | sed 's/\./ /g'))
}

nix_build() {
    local file="$1" # points to a project's default.nix

    command="nix-build --arg ngipkgs \"import /ngipkgs {}\" -o /result \"$file\""

    # Nix versions < 2.24 don't work for our use case due to regression in
    # closureInfo.
    # https://github.com/NixOS/nix/issues/6820
    if [ "$(nix_version)" -ge 22400 ]; then
        echo "Using Nix installed by Linux package manager"
        eval "$command"
    else
        echo "Using Nix from Nixpkgs unstable"

        nixpkgs_revision=$(
            nix-instantiate --eval --attr sources.nixpkgs.rev /ngipkgs |
                jq --raw-output
        )
        export NIXPKGS="https://github.com/NixOS/nixpkgs/archive/$nixpkgs_revision.tar.gz"
        nix-shell --include nixpkgs="$NIXPKGS" --packages nix --run "$command"
    fi
}

test_demo() {
    if [[ "$PROJECT" == "Cryptpad" ]]; then
        echo -e "\n---> Launching VM ..."
        /result &
        curl --retry 10 --retry-all-errors --fail localhost:9000 | grep CryptPad
    elif [[ "$PROJECT" == "mitmproxy" ]]; then
        echo -e "\n---> Entering Shell ..."
        source /result
        mitmproxy --version
    else
        echo "ERROR: Demo for $PROJECT not found. Exiting ..."
        exit 1
    fi
}

echo -e "\n-> Installing Nix ..."
install_nix

echo -e "\n-> Nix version ..."
echo "Nix version: $(nix_version)"

echo -e "\n-> Testing $PROJECT ..."

echo -e "\n---> Building test ..."
nix_build "/overview/project/$PROJECT/default.nix"

echo -e "\n---> Running test ..."
test_demo
