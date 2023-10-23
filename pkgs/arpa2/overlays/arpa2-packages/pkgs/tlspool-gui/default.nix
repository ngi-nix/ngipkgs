{
  stdenv,
  lib,
  helpers,
  tlspool,
  qtbase,
  wrapQtAppsHook,
  fetchFromGitLab,
}:
helpers.mkArpa2Derivation rec {
  pname = "tlspool-gui";
  version = "0.0.6";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "tlspool-gui";
    rev = "v${version}";
    hash = "sha256-87AY5GxIeDvsc9jrjam1aAYK+RQwhEgt+GO4TE4d6Js=";
  };

  nativeBuildInputs = [tlspool wrapQtAppsHook];
  buildInputs = [qtbase];
}
