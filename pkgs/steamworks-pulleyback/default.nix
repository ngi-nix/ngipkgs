{ src, stdenv, cmake, arpa2cm, arpa2common, steamworks, lua, doxygen, graphviz
, libressl, lmdb, libuuid }:
stdenv.mkDerivation {
  inherit src;

  name = "steamworks";

  nativeBuildInputs =
    [ cmake arpa2cm steamworks arpa2common lua doxygen graphviz libuuid ];

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
