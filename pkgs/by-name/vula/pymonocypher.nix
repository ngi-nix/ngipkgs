{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "pymonocypher";
  version = "4.0.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jetperch";
    repo = "pymonocypher";
    rev = "v${version}";
    hash = "sha256-3vnF2MnrjI7pRiOTjPZ0D8tDojfdGJ2kSlLqF7Kkp5Y=";
  };

  build-system = with python3Packages; [
    cython
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "monocypher"
  ];

  meta = {
    description = "Python ctypes bindings to the Monocypher library";
    homepage = "https://pypi.org/project/pymonocypher/";
    license = with lib.licenses; [
      cc0
      bsd2
    ];
    mainProgram = "pymonocypher";
  };
}
