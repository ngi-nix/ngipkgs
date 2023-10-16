{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quickder,
  gperf,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [quickder gperf];
}
