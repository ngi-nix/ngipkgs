{
  autoreconfHook,
  curl,
  fetchgit,
  gnunet,
  jansson,
  lib,
  libgcrypt,
  libmicrohttpd,
  libsodium,
  pkg-config,
  stdenv,
}:
let
  version = "0.9.4";
in
stdenv.mkDerivation {
  inherit version;
  pname = "twister";

  src = fetchgit {
    url = "https://git.taler.net/twister.git";
    rev = "v${version}";
    hash = "sha256-QxyK0FIWlGnM9GMH7rXpM4nIDozlXyAgMbUuwNqMymo=";
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
    libsodium
  ];

  doInstallCheck = true;

  meta = {
    homepage = "https://git.taler.net/twister.git";
    description = "Fault injector for HTTP traffic.";
    license = lib.licenses.agpl3Plus;
  };
}
