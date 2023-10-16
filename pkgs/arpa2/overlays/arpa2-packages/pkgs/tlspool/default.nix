{
  src,
  pname,
  version,
  stdenv,
  helpers,
  quickder,
  gnutls,
  db,
  ldns,
  libtasn1,
  p11-kit,
  unbound,
  libkrb5,
  openldap,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [quickder gnutls db ldns libtasn1 p11-kit unbound libkrb5 openldap];
}
