{
  src,
  pname,
  version,
  stdenv,
  cmake,
  pkgconfig,
  flex,
  bison,
  lksctp-tools,
  libidn,
  libgcrypt,
  gnutls,
}:
stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [cmake pkgconfig flex bison lksctp-tools libidn libgcrypt gnutls];

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
