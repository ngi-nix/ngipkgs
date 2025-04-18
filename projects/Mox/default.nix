{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Modern full-featured open source secure mail server for low-maintenance self-hosted email";
    subgrants = [
      "Mox"
      "Mox-API"
      "Mox-Automation"
    ];
    links = {
      website = {
        text = "Mox website";
        url = "https://www.xmox.nl/";
      };
    };
  };

  nixos.modules.programs = {
    mox = {
      name = "mox";
      module = ./programs/mox/module.nix;
      examples.basic = {
        module = ./programs/mox/examples/basic.nix;
        description = "";
        tests.basic = import ./programs/mox/tests/basic.nix args;
      };
      links = {
        build = {
          text = "Mox source";
          url = "https://github.com/mjl-/mox";
        };
      };
    };
  };

}
