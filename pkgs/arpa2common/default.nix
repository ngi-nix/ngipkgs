{ src, stdenv, cmake, arpa2cm, ragel, lmdb, libressl, libsodium, pkgconfig
, libkrb5, e2fsprogs, doxygen, graphviz }:
stdenv.mkDerivation {
  inherit src;

  name = "arpa2common";

  nativeBuildInputs = [
    cmake
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

  propagatedBuildInputs = [ arpa2cm lmdb libkrb5 libressl ];

  configurePhase = ''
    export PREFIX=$out
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make install
  '';

  # The project uses single argument `printf` throughout the program
  # Disabeling this seems like the easiest fix
  hardeningDisable = [ "format" ];
}
