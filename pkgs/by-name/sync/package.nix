{
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
}: let
  version = "0.9.3";
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
      gnunet
      jansson
      libgcrypt
      libmicrohttpd
      libsodium
      pkg-config
      postgresql
    ];
  }
