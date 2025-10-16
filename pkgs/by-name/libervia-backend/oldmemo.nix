{
  lib,
  python3Packages,
  callPackage,
  fetchFromGitHub,
}:
let
  omemo = callPackage ./omemo.nix { };
in
python3Packages.buildPythonPackage rec {
  pname = "oldmemo";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-oldmemo";
    rev = "refs/tags/v${version}";
    hash = "sha256-iAsp42VcGsf3Nhk0I97Wi3SlpLxcA6BkVaFm1yY0HrY=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = [
    omemo
  ]
  ++ (with python3Packages; [
    cryptography
    doubleratchet
    protobuf
    x3dh
  ]);

  pythonImportsCheck = [
    "oldmemo"
  ];

  meta = {
    description = "Backend implementation of the eu.siacs.conversations.axolotl namespace for python-omemo";
    homepage = "https://github.com/Syndace/python-oldmemo";
    changelog = "https://github.com/Syndace/python-oldmemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
  };
}
