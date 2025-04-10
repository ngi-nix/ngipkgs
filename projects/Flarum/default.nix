{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Flarum is a technically advanced, open and extensible discussion platform.";
    subgrants = [
      "Flarum"
    ];
  };

  nixos.modules.programs = {
    flarum = {
      name = "flarum";
      module = ./module.nix;
      examples.basic = {
        module = ./programs-example.nix;
        description = "";
        tests.basic = null;
      };
      links = {
        build = {
          text = "Installation";
          url = "https://github.com/flarum/cli#installation";
        };
        test = {
          text = "cli test";
          url = "https://github.com/flarum/cli/tree/3.x/test";
        };
      };
    };
  };

  nixos.modules.services = {
    flarum = {
      name = "flarum";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/flarum.nix";
      examples.basic = {
        module = ./services-example.nix;
        description = "";
        tests.basic = null;
      };
      links = {
        build = {
          text = "Flarum installation";
          url = "https://github.com/flarum/cli#installation";
        };
        test = {
          text = "Flarum services";
          url = "https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/web-apps/flarum.nix";
        };
      };
    };
  };
}
