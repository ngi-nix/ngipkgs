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

  solidpython = callPackage ./solidpython {};

  # https://github.com/yaqwsx/KiKit/issues/574
  shapelyPkgsRoot = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "8d8e62e74f511160a599471549a98bc9e4f4818d";
    sha256 = "sha256-2vm6IAnaCo5KAA5/rWSb6dzJsS/raEqR93xbM2/jgng=";
  };

  shapelyFile = "${shapelyPkgsRoot}/pkgs/development/python-modules/shapely";

  shapely =
    python3.pkgs.callPackage
    shapelyFile
    {};
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
