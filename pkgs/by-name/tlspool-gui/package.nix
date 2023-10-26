{
  stdenv,
  lib,
  cmake,
  arpa2common,
  arpa2cm,
  tlspool,
  libsForQt5,
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "tlspool-gui";
  version = "0.0.6";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "tlspool-gui";
    rev = "v${version}";
    hash = "sha256-87AY5GxIeDvsc9jrjam1aAYK+RQwhEgt+GO4TE4d6Js=";
  };

  nativeBuildInputs = [cmake arpa2common arpa2cm tlspool libsForQt5.qt5.wrapQtAppsHook];
  buildInputs = [libsForQt5.qt5.qtbase];
}
