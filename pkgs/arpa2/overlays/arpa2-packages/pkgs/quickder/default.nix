{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quickmem,
  python37,
  ensureNewerSourcesHook,
}: let
  python-with-packages =
    python37.withPackages
    (ps: with ps; [setuptools asn1ate six pyparsing colored]);
in
  helpers.mkArpa2Derivation {
    inherit src pname version;

    nativeBuildInputs = [quickmem python-with-packages];

    buildInputs = [
      # Why DOS, why didn't you just make epcoh 1970...
      (ensureNewerSourcesHook {year = "1980";})
    ];
  }
