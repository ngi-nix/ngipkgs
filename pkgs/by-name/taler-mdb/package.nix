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
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-mdb";
  version = "1.0.0";

  src = fetchgit {
    url = "https://git.taler.net/taler-mdb.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AAFnF8bN2Pnhy8OZbgA6CRHBIC6iP785HpVjPEVu+IQ=";
    fetchSubmodules = true;
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

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    homepage = "https://git.taler.net/taler-mdb.git";
    description = "Sales integration with the Multi-Drop-Bus of Snack machines, NFC readers and QR code display.";
    license = lib.licenses.agpl3Plus;
  };
})
