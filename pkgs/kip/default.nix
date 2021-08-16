{ src, stdenv, cmake, pkgconfig, arpa2cm, arpa2common, quick-mem, quick-der
, quick-sasl, unbound, openssl, e2fsprogs, cyrus_sasl, libkrb5, libev, json_c
, bison, flex, freeDiameter, python3, libressl, cacert, gnutls }:
let
  python-with-packages = python3.withPackages
    (ps: with ps; [ setuptools asn1ate six pyparsing colored ]);
in stdenv.mkDerivation {
  inherit src;

  name = "kip";

  nativeBuildInputs = [ cmake pkgconfig cacert openssl libressl gnutls ];

  buildInputs = [
    arpa2cm
    arpa2common
    quick-mem
    quick-der
    quick-sasl
    unbound
    e2fsprogs
    cyrus_sasl
    libkrb5
    libev
    json_c
    bison
    flex
    freeDiameter
    python-with-packages
  ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
    patchShebangs test
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install . --prefix $out
  '';
}
