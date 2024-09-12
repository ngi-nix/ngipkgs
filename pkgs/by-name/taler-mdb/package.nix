{
  autoreconfHook,
  curl,
  fetchgit,
  gnunet,
  jansson,
  lib,
  libgcrypt,
  libmicrohttpd,
  libnfc,
  libsodium,
  pkg-config,
  stdenv,
  taler-exchange,
  taler-merchant,
  qrencode,
}: let
  version = "0.13.0";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "taler-mdb";

    src = fetchgit {
      url = "https://git.taler.net/taler-mdb.git";
      rev = "v${version}";
      hash = "sha256-vc9e2fFiNvbgPY52moBVKVvrcvH0I4mxvSQK5IL7lBE=";
    };

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ];

    buildInputs = [
      curl
      gnunet
      jansson
      libgcrypt
      libmicrohttpd
      libnfc
      libsodium
      qrencode
      taler-exchange
      taler-merchant
    ];

    doInstallCheck = true;

    meta = {
      homepage = "https://git.taler.net/taler-mdb.git";
      description = "Sales integration with the Multi-Drop-Bus of Snack machines, NFC readers and QR code display.";
      license = lib.licenses.agpl3Plus;
    };
  }
