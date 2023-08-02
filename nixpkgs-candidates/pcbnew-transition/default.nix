{
  python3,
  fetchPypi,
  lib,
}: let
  inherit (python3.pkgs) buildPythonPackage;

  properCaseName = "pcbnewTransition";
in
  buildPythonPackage rec {
    pname = properCaseName;
    version = "0.3.4";
    format = "setuptools";

    disabled = python3.pythonOlder "3.7";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-3CJUG1kd63Lg0r9HpJRIvttHS5s2EuZRoxeXrqsJ/kQ=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      kicad
    ];

    nativeBuildInputs = with python3.pkgs; [
      versioneer
    ];

    pythonImportsCheck = [
      properCaseName
    ];

    meta = with lib; {
      description = "Library that allows you to support both, KiCAD 5 and KiCAD 6 in your plugins";
      homepage = "https://github.com/yaqwsx/pcbnewTransition";
      changelog = "https://github.com/yaqwsx/pcbnewTransition/releases/tag/v${version}";
      license = licenses.mit;
    };
  }
