{ src, pname, version, stdenv, cmake, arpa2cm, ragel, lmdb, libressl, libsodium
, pkgconfig, libkrb5, e2fsprogs, doxygen, graphviz }:

stdenv.mkDerivation rec {
  inherit src pname version;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    arpa2cm
    ragel
    lmdb
    libressl
    libsodium
    pkgconfig
    libkrb5
    e2fsprogs
    doxygen
    graphviz
  ];

  propagatedBuildInputs = buildInputs;

  postUnpack = ''
    rm -rf Makefile
  '';

  # The project uses single argument `printf` throughout the program
  # Disabeling this seems like the easiest fix
  hardeningDisable = [ "format" ];
}
