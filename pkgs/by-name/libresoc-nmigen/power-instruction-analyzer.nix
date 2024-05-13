{
  lib,
  python39Packages,
  rustPlatform,
  fetchFromLibresoc,
}:
python39Packages.buildPythonPackage rec {
  pname = "power-instruction-analyzer";
  version = "0.2.0";
  format = "pyproject";

  src = fetchFromLibresoc {
    inherit pname;
    rev = "v${version}";
    hash = "sha256-UmgDykG9yn413PXrMsI4oRblCZdHbtaIZ55p89YPfQs=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-lkSdkkU0lvGtEHbM3eFrXHiUcWEPkHL1sQeebAyMUcY=";
  };

  nativeBuildInputs = with rustPlatform; [cargoSetupHook maturinBuildHook];
  maturinBuildFlags = "-F python";

  meta = {
    description = "Program to analyze the behavior of Power ISA instructions";
    homepage = "https://git.libre-soc.org/?p=power-instruction-analyzer.git;a=summary";
    license = lib.licenses.lgpl21Plus;
  };
}
