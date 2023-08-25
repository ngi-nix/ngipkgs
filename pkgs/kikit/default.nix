{
  lib,
  pcbnew-transition,
  pybars3,
  python3,
  fetchFromGitHub,
  bats,
  callPackage,
}: let
  properCaseName = "KiKit";

  shapely = callPackage ./shapely {};
  solidpython = callPackage ./solidpython {};
in
  python3.pkgs.buildPythonPackage rec {
    pname = lib.toLower properCaseName;
    version = "1.3.0";
    format = "setuptools";

    disabled = python3.pythonOlder "3.7";

    src = fetchFromGitHub {
      owner = "yaqwsx";
      repo = properCaseName;
      rev = "v${version}";
      hash = "sha256-kDTPk/R3eZtm4DjoUV4tSQzjGQ9k8MKQedX4oUXYzeo=";
    };

    propagatedBuildInputs = with python3.pkgs;
      [
        kicad
        numpy
        click
        markdown2
        commentjson
        # https://github.com/yaqwsx/KiKit/issues/575
        wxPython_4_2
      ]
      ++ [
        pcbnew-transition
        shapely
        pybars3
        # https://github.com/yaqwsx/KiKit/issues/576
        solidpython
      ];

    nativeBuildInputs = with python3.pkgs; [
      versioneer
    ];

    nativeCheckInputs = with python3.pkgs;
      [
        pytest
      ]
      ++ [
        bats
      ];

    pythonImportsCheck = [
      pname
    ];

    checkPhase = ''
      runHook preCheck
      export PATH=$PATH:$out/bin
      make test
      runHook postCheck
    '';

    meta = with lib; {
      description = "Automation for KiCAD boards";
      homepage = "https://github.com/yaqwsx/KiKit/";
      changelog = "https://github.com/yaqwsx/KiKit/releases/tag/v${version}";
      license = licenses.mit;
    };
  }
