{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
    Mox is a modern, secure, and open-source email server that implements all modern email protocols.
    It makes it easy for people and organizations to run their own email server in minutes using mox quickstart.
    '';
    subgrants = [
      "Mox"
    ];
  };

  # Mox Service
  nixos.modules.services = {
    mox = {
      name = "mox";
      module = ./module.nix;
      examples.mox = {
        module = ./example.nix;
        description = "";
        tests.basic = import ./test.nix args;
      };
      links = {
        install = {
          text = "Mox Install Documentation";
          url = "https://www.xmox.nl/install/";
        };
        repository = {
          text = "Mox Github Repository";
          url = "https://github.com/mjl-/mox";
        };
      };
    };
  };
}
