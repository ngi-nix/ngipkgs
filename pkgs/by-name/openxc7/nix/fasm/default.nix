# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  cmake,
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
    hash = "sha256-ZytcNJvXs+GUSIrf4dtYl+Hc5kEQmeJP+3BQOmQImIw=";
  };

  nativeBuildInputs = [
    cmake
    cython
  ];

  propagatedBuildInputs = [
    textx
  ];

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
}
