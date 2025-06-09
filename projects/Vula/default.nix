{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Encrypted ad hoc local-area networking";
    subgrants = [
      "Vula"
      "Vula-IPV6-Reunion"
    ];
  };

  nixos.modules.services.vula = {
    module = ./service.nix;
    examples.simple = {
      module = ./example-simple.nix;
      description = ''
        Simple configuration for Vula. Vula nodes will automatically discover each other on networks that support [multicast DNS](https://en.wikipedia.org/wiki/Multicast_DNS) (mDNS).

        Add users to the group defined in `config.services.vula.operatorsGroup` to grant them permissions to manage Vula through the `vula` command.
      '';
      # FIX: https://buildbot.ngi.nixos.org/#/builders/193/builds/1789
      # tests.test = import ./test.nix args;
      tests.test = null;
    };
  };
}
