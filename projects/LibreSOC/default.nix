{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Fully open hardware System-on-a-Chip";
    subgrants = {
      Entrust = [
        "Libre-SOC-HPC"
        "Libre-SOC-OpenPOWER-ISA"
      ];
      Review = [
        "Cavatools"
        "Libre-RISCV"
        "LibreSoC-3Ddriver"
        "LibreSoC-Proofs"
        "LibreSoC-Standards"
        "LibreSoC-Video"
      ];
    };
  };

  # https://libre-soc.org/nlnet_2022_ongoing/
  nixos.modules.programs = {
    libresoc = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };

  # FIX: https://github.com/NixOS/nixpkgs/issues/389149
  # binary = {
  #   "libresoc.v".data = pkgs.libresoc-verilog;
  # };
}
