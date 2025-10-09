{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Remote sharing of terminal sessions";
    subgrants = {
      Core = [
        "Tau"
      ];
    };
    # Top-level links for things that are in common across the whole project (mandatory)
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/tau-org";
      };
      homepage = null;
      docs = null;
    };
  };

  nixos.modules.programs = {
    tau-radio = {
      module = ./programs/tau-radio/module.nix;
      examples."Enable tau-radio" = {
        module = ./programs/tau-radio/examples/basic.nix;
        tests.client.module = import ./programs/tau-radio/tests/basic.nix args;
      };
      links.repo = {
        text = "Source repository";
        url = "https://github.com/tau-org/tau-radio";
      };
    };
  };

  nixos.modules.services = {
    tau-tower = {
      module = ./services/tau-tower/module.nix;
      examples."Enable tau-tower" = {
        module = ./services/tau-tower/examples/basic.nix;
        tests.server.module = import ./services/tau-tower/tests/basic.nix args;
      };
      links.repo = {
        text = "Source repository";
        url = "https://github.com/tau-org/tau-tower";
      };
    };
  };
}
