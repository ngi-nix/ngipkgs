{
  pkg-config,
  stdenv,
  cmake,
  arpa2cm,
  arpa2common,
  quickmem,
  cyrus_sasl,
  quickder,
  libkrb5,
  libev,
  e2fsprogs,
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "quicksasl";
  version = "0.13.2";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "quick-sasl";
    rev = "v${version}";
    hash = "sha256-kMKZRromm/hb9PZwvWAzmJorSqTB8xMIbWASfSjajiQ=";
  };

  nativeBuildInputs = [
    cmake
    arpa2cm
    arpa2common
    libkrb5
    quickmem
    cyrus_sasl
    quickder
    libev
    e2fsprogs
    pkg-config
  ];
}
