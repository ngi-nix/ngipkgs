# SolidPython is an unmaintained library with old dependencies.
{
  python3,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchpatch,
  lib,
  euclid3,
}: let
  inherit
    (lib)
    licenses
    ;

  inherit
    (python3.pkgs)
    buildPythonPackage
    ;

  pypng = python3.pkgs.pypng.overrideAttrs (old: rec {
    version = "0.0.19";
    src = fetchFromGitLab {
      owner = "drj11";
      repo = "pypng";
      rev = "refs/tags/${old.pname}-${version}";
      hash = "sha256-XVsXgvLVFfxrRXDwdZO7oi7LPozN2XiYeXCK9NTx4Qs=";
    };
    patches = [
      (fetchpatch {
        url = "https://gitlab.com/drj11/pypng/-/commit/fe9c973c5e92f24746dfa1be8796c14a2befec4f.diff";
        hash = "sha256-OYO8TE4MRHhRmgLjetk4TajFT7INQ9WdjCRjDsGc+pg=";
      })
    ];

    disabledTests = [
      "test_test_dir"
    ];
  });
in
  buildPythonPackage rec {
    pname = "solidpython";
    version = "1.1.3";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "SolidCode";
      repo = "SolidPython";
      rev = "d962740d600c5dfd69458c4559fc416b9beab575";
      hash = "sha256-3fJta2a5c8hV9FPwKn5pj01aBtsCGSRCz3vvxR/5n0Q=";
    };

    nativeBuildInputs = [
      python3.pkgs.pythonRelaxDepsHook
    ];

    pythonRelaxDeps = [
      "PrettyTable"
    ];

    propagatedBuildInputs = with python3.pkgs;
      [
        ply
        prettytable
        setuptools
      ]
      ++ [
        (euclid3.override {inherit python3;})
        pypng
      ];

    buildInputs = with python3.pkgs; [
      poetry-core
    ];

    pythonImportsCheck = [
      "solid"
    ];

    meta = {
      description = "Python interface to the OpenSCAD declarative geometry language";
      homepage = "https://github.com/SolidCode/SolidPython";
      changelog = "https://github.com/SolidCode/SolidPython/releases/tag/v${version}";
      license = licenses.lgpl21Plus;
    };
  }
