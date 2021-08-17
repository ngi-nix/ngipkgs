{ src, stdenv, cmake, quick-der, arpa2cm, arpa2common, gperf }:
stdenv.mkDerivation {
  inherit src;

  name = "lillydap";

  nativeBuildInputs = [ cmake quick-der arpa2cm arpa2common gperf ];

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
