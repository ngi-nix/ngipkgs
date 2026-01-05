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
stdenv.mkDerivation (finalAttrs: {
  pname = "nextpnr-xilinx";
  version = "0.8.2-unstable-2025-11-25";

  src = fetchFromGitHub {
    owner = "openXC7";
    repo = "nextpnr-xilinx";
    rev = "3374e5a62b54dc346fd5f85188ed24075ddfd5fb";
    hash = "sha256-gW3Z3Cd5/gfX7k/ekRHtPVlbhKszWah1L+HggMFKakA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # fix build with gcc15
    substituteInPlace 3rdparty/json11/json11.cpp \
      --replace-fail "<climits>" "<climits>${"\n"}#include <cstdint>"
  '';

  nativeBuildInputs = [
    cmake
    git
  ];
  buildInputs = [
    python312Packages.boost
    python312
    eigen
  ]
  ++ (lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ]);

  cmakeFlags = [
    "-DCURRENT_GIT_VERSION=${lib.substring 0 7 finalAttrs.src.rev}"
    "-DARCH=xilinx"
    "-DBUILD_GUI=OFF"
    "-DBUILD_TESTS=OFF"
    "-DUSE_OPENMP=ON"
    "-Wno-deprecated"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp nextpnr-xilinx bbasm $out/bin/
    mkdir -p $out/share/nextpnr/external
    cp -rv ../xilinx/external/prjxray-db $out/share/nextpnr/external/
    cp -rv ../xilinx/external/nextpnr-xilinx-meta $out/share/nextpnr/external/
    cp -rv ../xilinx/python/ $out/share/nextpnr/python/
    cp ../xilinx/constids.inc $out/share/nextpnr
    runHook postInstall
  '';

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  meta = {
    description = "Place and route tool for FPGAs";
    homepage = "https://github.com/openXC7/nextpnr-xilinx";
    license = lib.licenses.isc;
    platforms = lib.platforms.all;
  };
})
