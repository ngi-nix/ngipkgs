{ src, stdenv, cmake, arpa2cm, openldap, flex, bison, sqlite, catch2, log4cpp }:
stdenv.mkDerivation {
  inherit src;

  name = "steamworks";

  nativeBuildInputs = [
    cmake
    arpa2cm
    openldap
    flex
    bison
    sqlite
    #catch2 # Currently makes the CMakeFile generate a wrong linker path
    log4cpp
  ];

  NIX_CFLAGS_COMPILE = "-pthread";

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
