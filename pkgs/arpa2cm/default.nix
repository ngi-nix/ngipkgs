{ src, stdenv, cmake }:

stdenv.mkDerivation {
  inherit src;

  name = "arpa2cm";

  nativeBuildInputs = [ cmake ];

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
