{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage rec {
  pname = "brython";
  version = "3.12.4";
  pyproject = true;

  # Need sdist for data files, otherwise bound to specific python version
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UFFLshwQBcb3wvBB06gvhuJK7tRECQyW/irNjwc67+4=";
  };

  postPatch = ''
    rm pyproject.toml
  '';

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  pythonImportsCheck = [
    "brython"
  ];

  meta = {
    description = "Implementation of Python 3 running in the browser";
    homepage = "https://brython.info";
    license = lib.licenses.bsd3;
    maintainers = [];
  };
}
