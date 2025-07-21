{
  lib,
  python3Packages,
  fetchFromGitHub,
  omemo,
}:
python3Packages.buildPythonPackage rec {
  pname = "twomemo";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-twomemo";
    tag = "v${version}";
    hash = "sha256-jkazeFdNK0iB76oyHbQu+TLaGz+SH/30CmqXk0K6Sy8=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = [
    omemo
  ]
  ++ (with python3Packages; [
    doubleratchet
    protobuf
    typing-extensions
    x3dh
    xeddsa
  ]);

  pythonImportsCheck = [
    "twomemo"
  ];

  meta = {
    description = "Backend implementation of the urn:xmpp:omemo:2 namespace for python-omemo";
    homepage = "https://github.com/Syndace/python-twomemo";
    changelog = "https://github.com/Syndace/python-twomemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
