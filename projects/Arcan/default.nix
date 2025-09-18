{
  lib,
  pkgs,
  sources,
  ...
}@args:
{

  metadata = {
    summary = "Explorative p2p protocol for fast and secure remote desktops";
    subgrants = {
      Core = [
        "Arcan-A12-directory"
        "Arcan-A12-tools"
      ];
      Entrust = [
        "Arcan-A12"
      ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://arcan-fe.com";
      };
      repo = {
        text = "Source repository";
        url = "https://github.com/letoram/arcan";
      };
      docs = {
        text = "Documentation";
        url = "https://github.com/letoram/arcan/wiki";
      };
    };
  };

  nixos.modules.programs = {
    arcan = {
      name = "arcan";
      module = ./module.nix;
      examples.base = {
        module = ./example.nix;
        description = "testing documentation";
        tests.basic.module = null;
      };
      links = {
        build = {
          text = "arcan Documentation";
          url = "https://github.com/letoram/arcan#compiling";
        };
        test = {
          text = "arcan Documentation";
          url = "https://github.com/letoram/arcan/tree/master/tests";
        };
      };
    };
  };
}
