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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-mdb";
  version = "0.14.1";

  src = fetchgit {
    url = "https://git.taler.net/taler-mdb.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QiIiEHW9yfTP6A/+sBubioe9R1mxsOrzW/u12p2en4U=";
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
})
