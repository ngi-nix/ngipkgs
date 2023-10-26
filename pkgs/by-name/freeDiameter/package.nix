{
  stdenv,
  cmake,
  pkg-config,
  flex,
  bison,
  lksctp-tools,
  libidn,
  libgcrypt,
  gnutls,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "freeDiameter";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "freeDiameter";
    repo = "freeDiameter";
    rev = version;
    hash = "sha256-hd71wR4b/pnAUcd2U4/InmubCAqkKUZeZTBrGTV3FSY=";
  };

  nativeBuildInputs = [cmake pkg-config flex bison lksctp-tools libidn libgcrypt gnutls];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake ..
  '';

  buildPhase = ''
    cmake --build .
  '';

  installPhase = ''
    cmake --install . --prefix $out
  '';
}
