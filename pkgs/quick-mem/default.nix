{ src, stdenv, cmake, arpa2cm, arpa2common }:
stdenv.mkDerivation {
  inherit src;

  name = "quick-mem";

  nativeBuildInputs = [ cmake arpa2common arpa2cm ];

  configurePhase = ''
    mkdir -p make
    cd make
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install .
  '';
}
