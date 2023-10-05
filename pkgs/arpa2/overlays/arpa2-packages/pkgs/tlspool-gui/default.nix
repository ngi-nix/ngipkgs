{
  src,
  pname,
  version,
  stdenv,
  lib,
  helpers,
  tlspool,
  qtbase,
  wrapQtAppsHook,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [tlspool wrapQtAppsHook];
  buildInputs = [qtbase];
}
