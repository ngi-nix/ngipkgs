{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pymonocypher";
  version = "4.0.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jetperch";
    repo = "pymonocypher";
    rev = "v${version}";
    hash = "sha256-3vnF2MnrjI7pRiOTjPZ0D8tDojfdGJ2kSlLqF7Kkp5Y=";
  };

  build-system = [
    python3.pkgs.cython
    python3.pkgs.setuptools
    python3.pkgs.wheel
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
