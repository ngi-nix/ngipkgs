{ src, stdenv, cmake, arpa2common }:
stdenv.mkDerivation {
  inherit src;

  name = "quick-mem";

  nativeBuildInputs = [ cmake arpa2common ];

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
