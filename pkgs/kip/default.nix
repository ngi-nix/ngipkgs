{ src, stdenv, cmake, pkgconfig, arpa2cm, arpa2common, quick-mem, quick-der
, quick-sasl, unbound, openssl, e2fsprogs, cyrus_sasl, libkrb5, libev, json_c
, bison, flex, freeDiameter }:
stdenv.mkDerivation {
  inherit src;

  name = "kip";

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    arpa2cm
    arpa2common
    quick-mem
    quick-der
    quick-sasl
    unbound
    openssl
    e2fsprogs
    cyrus_sasl
    libkrb5
    libev
    json_c
    bison
    flex
    freeDiameter
  ];

  configurePhase = ''
    mkdir -p build
    cmake -S . -B build
  '';

  buildPhase = ''
    cmake --build build
  '';

  installPhase = ''
    cmake --install build --prefix $out
  '';
}
