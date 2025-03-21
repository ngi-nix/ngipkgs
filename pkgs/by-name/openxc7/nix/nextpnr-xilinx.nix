{
  stdenv,
  cmake,
  git,
  lib,
  fetchFromGitHub,
  python312Packages,
  python312,
  eigen,
  llvmPackages,
  ...
}:
stdenv.mkDerivation rec {
  pname = "nextpnr-xilinx";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "openXC7";
    repo = "nextpnr-xilinx";
    rev = "3374e5a62b54dc346fd5f85188ed24075ddfd5fb";
    hash = "sha256-gW3Z3Cd5/gfX7k/ekRHtPVlbhKszWah1L+HggMFKakA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    git
  ];
  buildInputs = [
    python312Packages.boost
    python312
    eigen
  ] ++ (lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ]);

  cmakeFlags = [
    "-DCURRENT_GIT_VERSION=${lib.substring 0 7 src.rev}"
    "-DARCH=xilinx"
    "-DBUILD_GUI=OFF"
    "-DBUILD_TESTS=OFF"
    "-DUSE_OPENMP=ON"
    "-Wno-deprecated"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp nextpnr-xilinx bbasm $out/bin/
    mkdir -p $out/share/nextpnr/external
    cp -rv ../xilinx/external/prjxray-db $out/share/nextpnr/external/
    cp -rv ../xilinx/external/nextpnr-xilinx-meta $out/share/nextpnr/external/
    cp -rv ../xilinx/python/ $out/share/nextpnr/python/
    cp ../xilinx/constids.inc $out/share/nextpnr
  '';

  meta = with lib; {
    description = "Place and route tool for FPGAs";
    homepage = "https://github.com/openXC7/nextpnr-xilinx";
    license = licenses.isc;
    platforms = platforms.all;
  };
}
