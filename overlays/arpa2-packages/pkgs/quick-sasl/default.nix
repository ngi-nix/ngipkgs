{ src, pname, version, stdenv, cmake, arpa2cm, arpa2common, quick-mem
, cyrus_sasl, quick-der, pkgconfig, libkrb5, libev, e2fsprogs }:

stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [
    cmake
    pkgconfig
    libkrb5
    arpa2cm
    arpa2common
    quick-mem
    cyrus_sasl
    quick-der
    libev
    e2fsprogs
  ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install . --prefix $out
  '';
}
