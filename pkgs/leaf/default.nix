{ src, stdenv, cmake, arpa2cm, quick-der, lillydap }:
stdenv.mkDerivation {
  inherit src;

  name = "leaf";

  nativeBuildInputs = [ cmake arpa2cm quick-der lillydap ];

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
