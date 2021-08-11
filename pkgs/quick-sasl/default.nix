{ src, stdenv, cmake, arpa2cm, arpa2common, quick-mem, cyrus_sasl, quick-der
, pkgconfig, libkrb5, libev, et }:
stdenv.mkDerivation {
  inherit src;

  name = "quick-sasl";

  nativeBuildInputs = [
    cmake
    libkrb5
    arpa2cm
    arpa2common
    quick-mem
    cyrus_sasl
    quick-der
    pkgconfig
    libev
  ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake --debug-find ..
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install -DCMAKE_INSTALL_PREFIX=$out .
  '';
}
