{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Interactive text/OS terminal inside WebXR";
    subgrants = [
      "xrsh"
    ];
    links = {
      install = {
        text = "Install Manual";
        url = "https://forgejo.isvery.ninja/xrsh/xrsh#install";
      };
      source = {
        text = "xrsh forgejo repository";
        url = "https://forgejo.isvery.ninja/xrsh/xrsh";
      };
    };
  };

  nixos.modules.programs = {
    xrsh = {
      module = ./programs/xrsh/module.nix;
    };
  };

  nixos.modules.services.xrsh.module = null;

  nixos.demo.shell = {
    module = ./programs/xrsh/examples/basic.nix;
    description = "xrsh example";
    tests.basic.module = import ./programs/xrsh/tests/basic.nix args;
  };
}
