{
  stdenv,
  helpers,
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
  fetchFromGitLab,
}:
helpers.mkArpa2Derivation rec {
  pname = "tlspool";
  version = "0.9.6";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "tlspool";
    rev = "v${version}";
    hash = "sha256-cscA7204nONYyuthDoVOlVwN1AW2EtvSamXpqjAAaqY=";
  };

  nativeBuildInputs = [quickder gnutls db ldns libtasn1 p11-kit unbound libkrb5 openldap pkg-config];
}
