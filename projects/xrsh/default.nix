{
  lib,
  pkgs,
  sources,
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
      examples.basic = {
        module = ./programs/xrsh/examples/basic.nix;
        description = "Basic example of using xrsh";
        tests.basic = import ./programs/xrsh/tests/basic.nix args;
      };
    };
  };

  nixos.examples.demo-shell = {
    module = ./programs/xrsh/examples/basic.nix;
    description = "xrsh demo";
    test.basic = import ./programs/xrsh/tests/basic.nix args;
  };

  nixos.modules.services.xrsh = null;
}
