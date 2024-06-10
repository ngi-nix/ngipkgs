{pkgs, ...} @ args: {
  packages = {inherit (pkgs) vula;};
  nixos.modules.services.vula = ./service.nix;
  nixos.tests.test = import ./test.nix args;
  nixos.examples.simple = {
    path = ./example-simple.nix;
    description = ''
      Simple configuration for Vula. Vula nodes will automatically discover each other on networks that support [multicast DNS](https://en.wikipedia.org/wiki/Multicast_DNS) (mDNS).

      Add users to the group defined in `config.services.vula.adminGroup` to grant them permissions to manage Vula through the `vula` command.
    '';
  };
}
