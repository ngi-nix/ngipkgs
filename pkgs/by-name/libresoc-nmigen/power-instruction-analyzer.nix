{
  lib,
  python3Packages,
  rustPlatform,
  fetchFromLibresoc,
}:
python3Packages.buildPythonPackage rec {
  pname = "power-instruction-analyzer";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromLibresoc {
    inherit pname;
    rev = "v${version}";
    hash = "sha256-UmgDykG9yn413PXrMsI4oRblCZdHbtaIZ55p89YPfQs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-zQrfQWzo76CJhD5oCfyjKq0dyw+XNWpkFlZLnQ92WJQ=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];
  maturinBuildFlags = "-F python";

  meta = {
    description = "Program to analyze the behavior of Power ISA instructions";
    homepage = "https://git.libre-soc.org/?p=power-instruction-analyzer.git;a=summary";
    license = lib.licenses.lgpl21Plus;
  };
}
