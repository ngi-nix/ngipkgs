{
  stdenv,
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
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "tlspool";
  version = "0.9.7";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "tlspool";
    rev = "v${version}";
    hash = "sha256-nODnRoFlgCTtBjPief9SkVlLgD3g+2zbwM0V9pt3Crk=";
  };

  nativeBuildInputs = [
    cmake
    arpa2common
    arpa2cm
    quickder
    gnutls
    db
    ldns
    libtasn1
    p11-kit
    unbound
    libkrb5
    openldap
    pkg-config
  ];
}
