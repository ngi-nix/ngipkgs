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

stdenv.mkDerivation (finalAttrs: {
  pname = "twister";
  version = "0.14.0";

  src = fetchgit {
    url = "https://git.taler.net/twister.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NyNULsvGEIa+cWX0WwegV9AjZj9HJkLHJrk2wOdORKs=";
  };

  postPatch = ''
    substituteInPlace src/twister/taler-twister-service.c \
      --replace-fail "gnunet_json" "gnunet_mhd" \
      --replace-fail "GNUNET_JSON" "GNUNET_MHD"
  '';

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
})
