{
  python3Packages,
  lib,
  fetchFromGitHub,
  doubleratchet,
  omemo,
  x3dh,
  xeddsa,
}:
python3Packages.buildPythonPackage rec {
  pname = "twomemo";
  version = "1.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-twomemo";
    rev = "refs/tags/v${version}";
    hash = "sha256-IQqRsDKW4PoBrJ4+WI6JSYoXf3dJFCN+2m2UY9EWHU4=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [setuptools];

  propagatedBuildInputs =
    [
      doubleratchet
      omemo
      x3dh
      xeddsa
    ]
    ++ (with python3Packages; [
      protobuf
      typing-extensions
    ]);

  pythonImportsCheck = [
    "twomemo"
  ];

  meta = {
    description = "Backend implementation of the urn:xmpp:omemo:2 namespace for python-omemo";
    homepage = "https://github.com/Syndace/python-twomemo";
    changelog = "https://github.com/Syndace/python-twomemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
