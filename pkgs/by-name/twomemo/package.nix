{
  lib,
  python3Packages,
  fetchFromGitHub,
  doubleratchet,
  omemo,
  x3dh,
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

  dependencies =
    [
      doubleratchet
      omemo
      x3dh
    ]
    ++ (with python3Packages; [
      protobuf
      typing-extensions
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
