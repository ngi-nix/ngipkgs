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
  version = "1.3.0";

  src = fetchgit {
    url = "https://git-www.taler.net/taler-mdb.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bslsC/m75kt8JoIQPp53u64SxghwZloOHehctphpNwI=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    curl
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
    homepage = "https://git-www.taler.net/taler-mdb.git";
    description = "Sales integration with the Multi-Drop-Bus of Snack machines, NFC readers and QR code display.";
    license = lib.licenses.agpl3Plus;
    teams = with lib.teams; [ ngi ];
  };
})
