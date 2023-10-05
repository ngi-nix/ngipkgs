{
  src,
  pname,
  version,
  stdenv,
  helpers,
}:
helpers.mkArpa2Derivation {inherit src pname version;}
