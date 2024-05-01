{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  curlWithGnuTls,
  gnunet,
  jansson,
  libgcrypt,
  libmicrohttpd,
  libsodium,
  pkg-config,
  postgresql,
  taler-exchange,
  taler-merchant,
}: let
  version = "0.10.1";
in
  stdenv.mkDerivation {
    pname = "sync";
    inherit version;

    src = fetchgit {
      url = "https://git.taler.net/sync.git";
      rev = "v${version}";
      hash = "sha256-7EBm4Zp1sjZw7pXxQySY+1It3C/KLG2SHhqUPhDATbg=";
    };

    nativeBuildInputs = [
      autoreconfHook
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

    buildInputs = [
      curlWithGnuTls
    ];

    # Tests run with `make check`.
    doCheck = false; # `test_sync_api` looks like an integration test

    meta = {
      homepage = "https://git.taler.net/sync.git";
      description = "Backup and synchronization service.";
      license = lib.licenses.agpl3Plus;
    };
  }
