# Upstream packages contain a bug, fixed by Enzime at https://github.com/Enzime/nixpkgs/update/taler
# Once Enzime's patch is fixed, taler-exchange and taler-merchant can be callpackaged from nixpkgs again.
{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  curl,
  gnunet,
  jansson,
  libgcrypt,
  libmicrohttpd,
  libsodium,
  pkg-config,
  postgresql,
  # taler-exchange,
  # taler-merchant,
  callPackage,
}: let
  version = "0.9.3";

  fixedExchangePkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/635096691eb96290fa415b28a57ec91383c767ae.tar.gz"; # Enzime/nixpkgs/update/taler
    sha256 = "0nksic7ywy23r2gnxzb59pkk432jflbv5jd0259b93c1ilg38nwf";
  }) {system = "x86_64-linux";};

  taler = callPackage ./taler.nix {libmicrohttpd_0_9_74 = callPackage ./libmicrohttpd.nix {};};
  taler-exchange = taler.taler-exchange;
  taler-merchant = taler.taler-merchant;
in
  stdenv.mkDerivation {
    name = "sync";
    inherit version;

    src = fetchgit {
      url = "https://git.taler.net/sync.git";
      rev = "v${version}";
      hash = "sha256-u4oR9zCBpBSqKFIhm+pLTH83tPLvYULt8FhDyTsP7m4=";
    };

    nativeBuildInputs = [
      autoreconfHook
      curl
      taler-exchange
      taler-merchant
      gnunet
      jansson
      libgcrypt
      libmicrohttpd
      libsodium
      pkg-config
      postgresql
    ];

    # Tests run with `make check`.
    doCheck = false; # `test_sync_api` looks like an integration test

    meta = {
      homepage = "https://git.taler.net/sync.git";
      description = "Backup and synchronization service.";
      license = lib.licenses.agpl3Plus;
    };
  }
