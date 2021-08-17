{ src, stdenv, lib, cmake, pkgconfig, arpa2cm, arpa2common, tlspool, qtbase
, wrapQtAppsHook }:
stdenv.mkDerivation {
  inherit src;

  name = "tlspool-gui";

  nativeBuildInputs =
    [ cmake pkgconfig arpa2cm arpa2common tlspool wrapQtAppsHook ];
  buildInputs = [ qtbase ];

  configurePhase = ''
    export PREFIX=$out
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make install
  '';
}
