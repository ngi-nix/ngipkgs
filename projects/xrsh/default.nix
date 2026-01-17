{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Interactive text/OS terminal inside WebXR";
    subgrants.Entrust = [
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
      examples."Enable xrsh and set a port to serve on" = {
        module = ./programs/xrsh/examples/basic.nix;
        description = ''
          This example shows how to enable xrsh and run a terminal inside WebXR.
        '';
        tests.basic.module = ./programs/xrsh/tests/basic.nix;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/xrsh/examples/basic.nix;
    module-demo = ./module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Run `xrsh` in the demo shell.
        '';
      }

      {
        instruction = ''
          Visit [http://127.0.0.1:8090](http://127.0.0.1:8090) on the browser to access the WebXR terminal.
        '';
      }
      {
        instruction = ''
          To change the web service port, set the environment variable `XRSH_PORT` before running the demo shell.
        '';
      }

    ];
    tests.basic.module = ./programs/xrsh/tests/basic.nix;
  };
}
