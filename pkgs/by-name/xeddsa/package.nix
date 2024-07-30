{
  python3Packages,
  lib,
  fetchFromGitHub,
  libsodium,
  libxeddsa,
}:
python3Packages.buildPythonPackage rec {
  pname = "xeddsa";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-xeddsa";
    rev = "refs/tags/v${version}";
    hash = "sha256-5/WQAd3Fdmjt2VteuwYZ5h9s3GW0CY1LJQCuv7xopJs=";
  };

  nativeBuildInputs = with python3Packages; [setuptools];

  buildInputs = [
    libsodium
    libxeddsa
  ];

  propagatedBuildInputs = with python3Packages; [cffi];

  pythonImportsCheck = [
    "xeddsa"
  ];

  meta = {
    description = "Python bindings to libxeddsa";
    homepage = "https://github.com/Syndace/python-xeddsa";
    changelog = "https://github.com/Syndace/python-xeddsa/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
