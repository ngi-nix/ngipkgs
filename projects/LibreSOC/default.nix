{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Fully open hardware System-on-a-Chip";
    subgrants = [
      "Libre-RISCV"
      "Libre-SOC-HPC"
      "Libre-SOC-OpenPOWER-ISA"
      "LibreSoC-3Ddriver"
      "LibreSoC-Proofs"
      "LibreSoC-Standards"
      "LibreSoC-Video"
    ];
  };

  # https://libre-soc.org/nlnet_2022_ongoing/
  nixos.programs = {
    libresoc = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };

  binary =
    # https://github.com/ngi-nix/ngipkgs/pull/773
    if builtins ? currentSystem then
      {
        "libresoc.v".data = pkgs.libresoc-verilog;
      }
    else
      { };
}
