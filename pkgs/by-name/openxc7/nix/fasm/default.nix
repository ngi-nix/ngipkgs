# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  cmake,
  jre_headless,
  antlr4_9,
  textx,
  cython,
  fetchpatch,
}:

buildPythonPackage rec {
  name = "fasm";
  version = "0.0.2.r98.g9a73d70";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    inherit name;
    owner = "openxc7";
    repo = "fasm";
    rev = "2f57ccb1727a120e8cacbb95c578f3c71bdcc95a";
    fetchSubmodules = true;
    hash = "sha256-4Na24czHPGvxuNuWKDiLkoBamsbqjGQkaQc8ogYHtuA=";
  };

  nativeBuildInputs = [
    cmake
    jre_headless
    cython
  ];

  buildInputs = [
    antlr4_9.runtime.cpp
  ];

  propagatedBuildInputs = [
    textx
  ];

  env.ANTLR4_RUNTIME_INCLUDE = "${antlr4_9.runtime.cpp.dev}/include/antlr4-runtime";

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "self.antlr_runtime = 'static'" "self.antlr_runtime = 'shared'"
  '';

  dontUseCmakeConfigure = true;

  # Broken upstream.
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=python-fasm-git#n76
  doCheck = false;

  meta = with lib; {
    changelog = "https://github.com/chipsalliance/fasm/releases/tag/${version}";
    homepage = "https://github.com/chipsalliance/fasm/";
    description = "FPGA Assembly (FASM) Parser and Generator";
    license = licenses.asl20;
    maintainers = with maintainers; [
      jleightcap
      hansfbaier
    ];
  };

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";
}
