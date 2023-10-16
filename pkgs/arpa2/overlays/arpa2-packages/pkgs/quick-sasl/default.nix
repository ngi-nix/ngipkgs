{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quick-mem,
  cyrus_sasl,
  quickder,
  libkrb5,
  libev,
  e2fsprogs,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [libkrb5 quick-mem cyrus_sasl quickder libev e2fsprogs];
}
