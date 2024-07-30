{
  python3Packages,
  lib,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "doubleratchet";
  version = "1.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-doubleratchet";
    rev = "refs/tags/v${version}";
    hash = "sha256-3IQqhKkd15uNRbupB9h0ZagurVXfiJt6NHvtr1fNZJQ=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [setuptools];

  propagatedBuildInputs = with python3Packages; [
    cryptography
    pydantic
    typing-extensions
  ];

  pythonImportsCheck = [
    "doubleratchet"
  ];

  meta = {
    description = "Python implementation of the Double Ratchet algorithm";
    homepage = "https://github.com/Syndace/python-doubleratchet";
    changelog = "https://github.com/Syndace/python-doubleratchet/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
