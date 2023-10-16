{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quickmem,
  cyrus_sasl,
  quickder,
  libkrb5,
  libev,
  e2fsprogs,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [libkrb5 quickmem cyrus_sasl quickder libev e2fsprogs];
}
