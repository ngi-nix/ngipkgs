{
  python3Packages,
  lib,
  fetchFromGitHub,
  doubleratchet,
  omemo,
  x3dh,
}:
python3Packages.buildPythonPackage rec {
  pname = "oldmemo";
  version = "1.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-oldmemo";
    rev = "refs/tags/v${version}";
    hash = "sha256-OR7VDkzwTMWOFpeJayY1DpH6yjOeCYm2Kf9MNQoRcXY=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [setuptools];

  propagatedBuildInputs =
    [
      doubleratchet
      omemo
      x3dh
    ]
    ++ (with python3Packages; [
      cryptography
      protobuf
    ]);

  pythonImportsCheck = [
    "oldmemo"
  ];

  meta = {
    description = "Backend implementation of the eu.siacs.conversations.axolotl namespace for python-omemo";
    homepage = "https://github.com/Syndace/python-oldmemo";
    changelog = "https://github.com/Syndace/python-oldmemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
