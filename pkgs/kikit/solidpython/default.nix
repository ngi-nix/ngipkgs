# SolidPython is an unmaintained library with old dependencies.
{
  python3,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchpatch,
  lib,
  euclid3,
}: let
  inherit (python3.pkgs) buildPythonPackage;

  # https://github.com/SolidCode/SolidPython/issues/207
  prettytablePkgsRoot = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "6dda65e8da23cc123060e3f24723471a15b3f0cd";
    sha256 = "sha256-1zdXZIs5C81slD+nLeIk5j+O/aAujejbiW4g07JHU5s=";
  };

  prettytableFile = "${prettytablePkgsRoot}/pkgs/development/python-modules/prettytable";

  prettytable =
    python3.pkgs.callPackage
    prettytableFile
    {
      # stdenv seems to have moved since then. Shim something that'll make this
      # old version of prettytable happy.
      stdenv = {
        inherit lib;
      };
    };

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

    propagatedBuildInputs = with python3.pkgs;
      [
        ply
        setuptools
      ]
      ++ [
        prettytable
        euclid3
        pypng
      ];

    buildInputs = with python3.pkgs; [
      poetry-core
    ];

    pythonImportsCheck = [
      "solid"
    ];

    meta = with lib; {
      description = "Python interface to the OpenSCAD declarative geometry language";
      homepage = "https://github.com/SolidCode/SolidPython";
      changelog = "https://github.com/SolidCode/SolidPython/releases/tag/v${version}";
      license = licenses.lgpl21Plus;
    };
  }
