{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Modern full-featured open source secure mail server";
    subgrants = {
      Core = [
        "Mox-Automation"
      ];
      Entrust = [
        "Mox"
      ];
      Review = [
        "Mox-API"
      ];
    };
    links = {
      install = {
        text = "Mox Install Documentation";
        url = "https://www.xmox.nl/install/";
      };
      source = {
        text = "Mox Github Repository";
        url = "https://github.com/mjl-/mox";
      };
    };
  };

  nixos.modules.programs = {
    mox = {
      name = "mox";
      module = ./programs/mox/module.nix;
      examples."Enable the Mox program" = {
        module = ./programs/mox/examples/basic.nix;
        description = "Use Mox subcommands to manage/debug the Mox server";
        tests.basic.module = ./programs/mox/tests/basic.nix;
      };
    };
  };

  nixos.modules.services = {
    mox = {
      name = "mox";
      module = ./services/mox/module.nix;
      examples."Enable the Mox server" = {
        module = ./services/mox/examples/basic.nix;
        description = "Mox server with optional hostname and user";
        tests.basic.module = ./services/mox/tests/basic.nix;
      };
    };
  };
}
