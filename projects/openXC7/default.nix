{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      Improve hardware support for open source FPGA tooling
    '';
    subgrants = [
      "openXC7"
    ];
  };

  nixos.programs = {
    openxc7 = {
      name = "openXC7";
      module = ./module.nix;
      examples.openxc7 = {
        module = ./example.nix;
        description = "";
        tests.compile-example = import ./test.nix args;
      };
    };
  };
}
