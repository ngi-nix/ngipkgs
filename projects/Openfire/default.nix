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
      module = ./services/openfire-server/module/default.nix;
      examples."Enable Openfire server" = {
        module = ./services/openfire-server/examples/basic/default.nix;
        tests.basic.module = import ./services/openfire-server/examples/basic/test.nix args;
      };
    };
  };
}
