{
  lib,
  python3,
  fetchgit,
}:
with builtins; let
  python = python3;
in
  python.pkgs.buildPythonApplication rec {
    pname = "highctidh";
    version = "1.0.2023121800";
    format = "pyproject";

    src = fetchgit {
      url = "https://codeberg.org/vula/highctidh";
      rev = "v${version}";
      hash = "sha256-83zTz5iBF/ApJV2hnsT2DfN/T36f73MrXmhLDJa5Z8I=";
    };

    postPatch = ''
      patchShebangs test.sh
      mkdir -p build/tmp
    '';

    propagatedBuildInputs = with python.pkgs; [
      setuptools
      build
    ];

    nativeBuildInputs = propagatedBuildInputs;

    doCheck = true;

    meta = with lib; {
      description = "Fork of high-ctidh as as a portable shared library with Python bindings.";
      homepage = "https://codeberg.org/vula/highctidh";
      license = licenses.gpl3;
      maintainers = with maintainers; [lorenzleutgeb];
    };
  }
