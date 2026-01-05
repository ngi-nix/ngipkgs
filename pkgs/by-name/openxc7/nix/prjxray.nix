{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  git,
  python312Packages,
  eigen,
  python312,
  ...
}:
stdenv.mkDerivation {
  pname = "prjxray";
  version = "0-unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "f4pga";
    repo = "prjxray";
    rev = "bdbc665852b82f589ff775a8f6498542dbec0a07";
    fetchSubmodules = true;
    hash = "sha256-lV4o62lS7CMG0EYPhp9bTB4fg0hOixy8CC8yGxKhGQE=";
  };

  nativeBuildInputs = [
    cmake
    git
  ];
  buildInputs = [
    python312Packages.boost
    python312
    eigen
  ];

  patchPhase = ''
    runHook prePatch
    # fix build with gcc15
    substituteInPlace third_party/yaml-cpp/src/emitterutils.cpp \
      --replace-fail "\"yaml-cpp/null.h\"" "\"yaml-cpp/null.h\"${"\n"}#include <cstdint>"
    substituteInPlace lib/include/prjxray/memory_mapped_file.h \
      --replace-fail "<absl/types/span.h>" "<absl/types/span.h>${"\n"}#include <cstdint>"
    runHook postPatch
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -v tools/xc7frames2bit tools/bitread tools/xc7patch $out/bin
    cp -v $srcs/utils/fasm2frames.py $out/bin/fasm2frames
    chmod 755 $out/bin/fasm2frames
    cp -v $srcs/utils/bit2fasm.py $out/bin/bit2fasm
    chmod 755 $out/bin/bit2fasm
    mkdir -p $out/usr/share/python3/
    cp -rv $srcs/prjxray $out/usr/share/python3/
    runHook postInstall
  '';

  doCheck = false;

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";
  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-deprecated"
    # fix build for gcc 15
    "-Wno-error=free-nonheap-object"
  ];

  meta = {
    description = "Xilinx series 7 FPGA bitstream documentation";
    homepage = "https://github.com/f4pga/prjxray";
    license = lib.licenses.isc;
    platforms = lib.platforms.all;
  };
}
