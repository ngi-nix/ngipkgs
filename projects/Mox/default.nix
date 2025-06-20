{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Modern full-featured open source secure mail server";
    subgrants = [
      "Mox"
      "Mox-API"
      "Mox-Automation"
    ];
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
      examples.basic = {
        module = ./programs/mox/examples/basic.nix;
        description = "Use Mox subcommands to manage/debug the Mox server";
        tests.basic = import ./programs/mox/tests/basic.nix args;
      };
    };
  };

  nixos.modules.services = {
    mox = {
      name = "mox";
      module = ./services/mox/module.nix;
      examples.basic = {
        module = ./services/mox/examples/basic.nix;
        description = "Mox server with optional hostname and user";
        tests.basic = import ./services/mox/tests/basic.nix args;
      };
    };
  };
}
