{
  python3Packages,
  lib,
  fetchFromGitHub,
  xeddsa,
}:
python3Packages.buildPythonPackage rec {
  pname = "x3dh";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-x3dh";
    rev = "refs/tags/v${version}";
    hash = "sha256-/hC1Kze4yBOlgbWJcGddcYty9fqwZ08Lyi0IiqSDibI=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs =
    [ xeddsa ]
    ++ (with python3Packages; [
      cryptography
      pydantic
      typing-extensions
    ]);

  pythonImportsCheck = [
    "x3dh"
  ];

  meta = {
    description = "Python implementation of the Extended Triple Diffie-Hellman key agreement protocol";
    homepage = "https://github.com/Syndace/python-x3dh";
    changelog = "https://github.com/Syndace/python-x3dh/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
