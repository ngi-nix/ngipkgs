{ src, stdenv, cmake, arpa2cm, arpa2common, quick-mem, python37
, ensureNewerSourcesHook }:
let
  python-with-packages = python37.withPackages
    (ps: with ps; [ setuptools asn1ate six pyparsing colored ]);
in stdenv.mkDerivation {
  inherit src;

  name = "quick-der";

  nativeBuildInputs =
    [ cmake arpa2common arpa2cm quick-mem python-with-packages ];

  buildInputs = [
    # Why DOS, why didn't you just make epcoh 1970...
    (ensureNewerSourcesHook { year = "1980"; })
  ];

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
