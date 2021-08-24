{ src, pname, version, stdenv, cmake, arpa2cm, quick-der, lillydap }:

stdenv.mkDerivation {
  inherit src pname version;

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
