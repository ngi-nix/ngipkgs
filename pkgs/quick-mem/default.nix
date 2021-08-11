{ src, stdenv, cmake, arpa2cm, arpa2common }:
stdenv.mkDerivation {
  inherit src;

  name = "quick-mem";

  nativeBuildInputs = [ cmake arpa2common arpa2cm ];

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
