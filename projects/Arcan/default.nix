{
  lib,
  pkgs,
  sources,
}@args:
{

  metadata = {
    summary = "Explorative p2p protocol for fast and secure remote desktops";
    subgrants = [
      "Arcan-A12"
      "Arcan-A12-directory"
      "Arcan-A12-tools"
    ];
  };

  nixos.modules.programs = {
    arcan = {
      name = "arcan";
      module = ./module.nix;
      examples.base = {
        module = ./example.nix;
        description = "testing documentation";
        tests.basic = null;
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
