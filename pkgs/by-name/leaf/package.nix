{
  stdenv,
  cmake,
  arpa2cm,
  arpa2common,
  quickder,
  quickmem,
  quicksasl,
  lillydap,
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "leaf";
  version = "0.2";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "leaf";
    rev = "v${version}";
    hash = "sha256-s52gtxM+BmG7oVrB5F0ORjkb4F3fWONiOxIWdDn2P5k=";
  };

  nativeBuildInputs = [
    cmake
    arpa2cm
    arpa2common
    quickder
    quickmem
    quicksasl
    lillydap
  ];
}
