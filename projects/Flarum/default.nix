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
      name = "Flarum";
      module = ./module.nix;
      examples.base = {
        module = ./example.nix;
        description = "Discussion community";
        tests.basic = null;
      };
      links = {
        build = {
          text = "Installation";
          url = "https://github.com/flarum/cli#installation";
        };
        test = {
          text = "Cli test";
          url = "https://github.com/flarum/cli/tree/3.x/test";
        };
      };
    };
  };

  nixos.modules.services = {
    services.flarum = {
      name = "services.flarum";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/flarum.nix";
      examples.basic = {
        module = ./example.nix;
        description = "The flarum package to use";
        tests.basic = null;
      };
      links = {
        build = {
          text = "flarum services";
          url = "https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/web-apps/flarum.nix";
        };
      };
    };
  };
}
