{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
  pname = "kivy-garden-modernmenu";
  version = "0-unstable-2019-12-10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kivy-garden";
    repo = "modernmenu";
    rev = "681c3bf68b9ce2ebe653c2e6a9fcd2407bfe3e00";
    hash = "sha256-0d4UhmRtuYwnYoZajjExavlvqkhGamiEQ8GjHWYnO88=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  checkInputs = with python3Packages; [
    kivy
  ];

  pythonImportsCheck = [
    "kivy_garden.modernmenu"
  ];

  preInstallCheck = ''
    export HOME=$PWD
  '';

  meta = {
    description = "Stylized menu system for Kivy";
    homepage = "https://github.com/kivy-garden/modernmenu";
    license = lib.licenses.mit;
    teams = [ lib.teams.ngi ];
  };
}
