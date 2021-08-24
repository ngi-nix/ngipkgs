{ src, pname, version, stdenv, cmake, arpa2cm, arpa2common, quick-der, gnutls
, db, ldns, libtasn1, p11-kit, unbound, libkrb5, pkgconfig, openldap }:

stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [
    cmake
    pkgconfig
    arpa2cm
    arpa2common
    quick-der
    gnutls
    db
    ldns
    libtasn1
    p11-kit
    unbound
    libkrb5
    openldap
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
