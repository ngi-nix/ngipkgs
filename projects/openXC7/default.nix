{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Improve hardware support for open source FPGA tooling
    '';
    subgrants.Entrust = [
      "openXC7"
    ];
  };

  nixos.modules.programs = {
    openxc7 = {
      name = "openXC7";
      module = ./module.nix;
      examples.openxc7 = {
        module = ./example.nix;
        description = "";
        tests.compile-example.module = ./test.nix;
      };
    };
  };
}
