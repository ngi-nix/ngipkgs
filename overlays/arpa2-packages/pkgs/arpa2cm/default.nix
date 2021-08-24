{ src, pname, version, stdenv, cmake }:

stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [ cmake ];

  postUnpack = ''
    rm -rf Makefile
  '';
}
