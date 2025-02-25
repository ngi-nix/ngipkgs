{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) marginalia-search;
  };
  nixos = {
    modules.services.marginalia-search = ./module.nix;
    tests.marginalia-search = import ./test.nix args;
    examples = {
      base = {
        description = ''
          A basic configuration of a MySQL database, Zookeeper, and Marginalia.

          Insecure practices are used here to make testing easy.
          For production usage, look into secrets management via Nix.
        '';
        path = ./example.nix;
      };
    };
  };
}
