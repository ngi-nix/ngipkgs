{ src, pname, version, stdenv, helpers, quick-der, gnutls, db, ldns, libtasn1
, p11-kit, unbound, libkrb5, openldap }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs =
    [ quick-der gnutls db ldns libtasn1 p11-kit unbound libkrb5 openldap ];
}
