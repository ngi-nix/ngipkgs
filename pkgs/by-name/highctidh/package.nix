{
  lib,
  python3,
  fetchgit,
}: let
  inherit (lib) licenses maintainers;

  version = "1.0.2024060500";
  src = fetchgit {
    url = "https://codeberg.org/vula/highctidh";
    rev = "v${version}";
    hash = "sha256-TyD5KzUz89RBxsSZeJYOkIzD29DF0BjizpMnsTpFOHI=";
  };
in
  python3.pkgs.buildPythonPackage {
    pname = "highctidh";
    inherit version src;
    pyproject = true;

    sourceRoot = "${src.name}/src";

    nativeBuildInputs = with python3.pkgs; [
      setuptools
    ];

    nativeCheckInputs = with python3.pkgs; [pytestCheckHook];

    meta = {
      description = "Fork of high-ctidh as as a portable shared library with Python bindings";
      homepage = "https://codeberg.org/vula/highctidh";
      license = licenses.publicDomain;
      maintainers = with maintainers; [lorenzleutgeb mightyiam];
    };
  }
