{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Real-time collaboration server based on the XMPP protocol";
    subgrants.Core = [
      "Openfire-IPv6"
      "Openfire-Connectivity"
    ];
  };

  nixos.modules.services = {
    openfire-server = {
      module = ./module.nix;
      examples."Enable Openfire server" = {
        module = ./example.nix;
        tests.basic.module = import ./test.nix args;
      };
    };
  };
}
