{
  lib,
  pybars3,
  python311,
  openscad,
  fetchFromGitHub,
  bats,
  callPackage,
}: let
  inherit
    (lib)
    toLower
    licenses
    ;

  properCaseName = "KiKit";

  python3 = python311;

  solidpython = callPackage ./solidpython {
    inherit python3;
  };
in
  python3.pkgs.buildPythonPackage rec {
    pname = toLower properCaseName;
    version = "1.5.1";
    format = "setuptools";

    disabled = python3.pythonOlder "3.7";

    src = fetchFromGitHub {
      owner = "yaqwsx";
      repo = properCaseName;
      rev = "v${version}";
      hash = "sha256-iehA6FthNTJq+lDTL4eSUIIlYDJj86LMOyv/L2/ybyc=";
    };

    propagatedBuildInputs = with python3.pkgs;
      [
        kicad
        numpy
        click
        markdown2
        commentjson
        # https://github.com/yaqwsx/KiKit/issues/575
        wxpython
        shapely
        pcbnew-transition
      ]
      ++ [
        (pybars3.override {inherit python3;})
        # https://github.com/yaqwsx/KiKit/issues/576
        solidpython
        openscad
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

    meta = {
      description = "Automation for KiCAD boards";
      homepage = "https://github.com/yaqwsx/KiKit/";
      changelog = "https://github.com/yaqwsx/KiKit/releases/tag/v${version}";
      license = licenses.mit;
    };
  }
