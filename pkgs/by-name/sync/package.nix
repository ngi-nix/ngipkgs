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
  taler-exchange,
  taler-merchant,
  callPackage,
}: let
  version = "0.9.3";
in
  stdenv.mkDerivation {
    pname = "sync";
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
