{
  python39Packages,
  rustPlatform,
  fetchFromLibresoc,
}:
with python39Packages;
with rustPlatform;
  buildPythonPackage rec {
    pname = "power-instruction-analyzer";
    version = "0.2.0";
    format = "pyproject";

    src = fetchFromLibresoc {
      inherit pname;
      rev = "v${version}";
      hash = "sha256-UmgDykG9yn413PXrMsI4oRblCZdHbtaIZ55p89YPfQs=";
    };

    cargoDeps = fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-lkSdkkU0lvGtEHbM3eFrXHiUcWEPkHL1sQeebAyMUcY=";
    };

    nativeBuildInputs = [cargoSetupHook maturinBuildHook];
    maturinBuildFlags = "-F python";
  }
