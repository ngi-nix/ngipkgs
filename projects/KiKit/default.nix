{
  lib,
  pkgs,
  sources,
}@args:

{
  # NOTE: this should probably be part of `KiCad`
  metadata = {
    summary = "Tooling for automation of production of PCB designed in KiCAD";
    subgrants = [
      "KiKit"
    ];
  };

  nixos.programs = {
    kikit = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
