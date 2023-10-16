{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quickder,
  lillydap,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [quickder lillydap];
}
