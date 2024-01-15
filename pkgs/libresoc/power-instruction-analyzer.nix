{pkgs, fetchgit, ...}:
with pkgs.python3Packages;
with pkgs.rustPlatform;
  buildPythonPackage rec {
    pname = "power-instruction-analyzer";
    version = "0.2.0";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/power-instruction-analyzer.git";
      rev = "v${version}";
      hash = "sha256-UmgDykG9yn413PXrMsI4oRblCZdHbtaIZ55p89YPfQs=";
    };

    cargoDeps = fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-lkSdkkU0lvGtEHbM3eFrXHiUcWEPkHL1sQeebAyMUcY=";
    };

    format = "pyproject";

    nativeBuildInputs = [cargoSetupHook maturinBuildHook];
  }
