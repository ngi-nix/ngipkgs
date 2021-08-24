{ src, pname, version, stdenv, cmake, quick-der, arpa2cm, arpa2common, gperf }:

stdenv.mkDerivation {
  inherit src pname version;

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
