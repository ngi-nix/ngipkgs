{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "modgrammar";
  version = "0.10";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uVfMnMW8xNo7B5XWPTPUIc8o2xhqyrdPg4R96DEfoJo=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "modgrammar"
  ];

  meta = {
    description = "Modular grammar-parsing engine";
    homepage = "https://pypi.org/project/modgrammar/";
    license = lib.licenses.bsd2;
    mainProgram = "modgrammar";
  };
}
