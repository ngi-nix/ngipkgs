{ src, stdenv, cmake }:

stdenv.mkDerivation {
  inherit src;

  name = "arpa2cm";

  nativeBuildInputs = [ cmake ];

  configurePhase = ''
    mkdir -p make
    cd make
    cmake .. cmake .. -DCMAKE_INSTALL_PREFIX=$out
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install .
  '';
}
