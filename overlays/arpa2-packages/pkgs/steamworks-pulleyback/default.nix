{ src, stdenv, cmake, arpa2cm, arpa2common, steamworks, lua, doxygen, graphviz
, libressl, lmdb, libuuid }:
stdenv.mkDerivation {
  inherit src;

  name = "steamworks-pulleyback";

  nativeBuildInputs =
    [ cmake arpa2cm steamworks arpa2common lua doxygen graphviz libuuid ];

  patches = [ ./install-dirs.patch ];

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
