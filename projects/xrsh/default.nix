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
      example."Enable xrsh" = {
        module = ./programs/xrsh/examples/basic.nix;
        description = ''
          This example shows how to enable xrsh and run a terminal inside WebXR.
          You can interact with the terminal using your VR controllers or hand tracking.
        '';
        tests.basic.module = import ./programs/xrsh/tests/basic.nix args;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/xrsh/examples/basic.nix;
    description = ''
      TODO(@themadbit): Write a proper instruction!
      This demo shows how to use xrsh to run a terminal inside WebXR.
      You can interact with the terminal using your VR controllers or hand tracking.
    '';
    tests.basic.module = import ./programs/xrsh/tests/basic.nix args;
  };
}
