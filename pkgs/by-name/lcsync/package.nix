{
  stdenv,
  pkgs,
  fetchFromGitea,
  lcrq,
  librecast,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  name = "lcsync";
  version = "0.2.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "librecast";
    repo = "lcsync";
    rev = "v${version}";
    sha256 = "sha256-RVfa0EmCPPT7ndy94YwD24S9pj7L11ztISaKHGcbTS8=";
  };
  buildInputs = [lcrq librecast pkgs.libsodium];
  configureFlags = ["SETCAP_PROGRAM=true"];
  installFlags = ["PREFIX=$(out)"];
  doCheck = true;

  meta = with lib; {
    homepage = "https://librecast.net/lcsync.html";
    changelog = "https://codeberg.org/librecast/lcsync/src/tag/v${version}/CHANGELOG.md";
    description = "Librecast File and Syncing Tool";
    license = [licenses.gpl2 licenses.gpl3];
  };
}
