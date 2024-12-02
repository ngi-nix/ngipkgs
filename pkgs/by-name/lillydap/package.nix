{
  stdenv,
  cmake,
  arpa2cm,
  arpa2common,
  quickder,
  gperf,
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "lillydap";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "lillydap";
    rev = "v${version}";
    hash = "sha256-SQuvu1A9Iq/fKthfYyVQGWFuyHYnhIry/wvnwgdMKHY=";
  };

  nativeBuildInputs = [
    cmake
    arpa2cm
    arpa2common
    quickder
    gperf
  ];
}
