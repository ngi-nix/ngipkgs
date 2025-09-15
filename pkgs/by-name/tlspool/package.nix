{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  arpa2common,
  arpa2cm,
  pkg-config,
  quickder,
  gnutls,
  db,
  ldns,
  libtasn1,
  p11-kit,
  unbound,
  libkrb5,
  openldap,
  openssl,
}:
# TODO: this has been migrated upstream, so remove after:
# https://github.com/NixOS/nixpkgs/pull/443114
stdenv.mkDerivation (finalAttrs: {
  pname = "tlspool";
  version = "0.9.7";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "tlspool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nODnRoFlgCTtBjPief9SkVlLgD3g+2zbwM0V9pt3Crk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    arpa2cm
    arpa2common
    cmake
    pkg-config
    libkrb5
  ];

  buildInputs = [
    arpa2cm
    db
    gnutls
    ldns
    libkrb5
    libtasn1
    openldap
    openssl
    p11-kit
    quickder
    unbound
  ];
})
