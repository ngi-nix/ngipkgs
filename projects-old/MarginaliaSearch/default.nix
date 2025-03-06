{
  pkgs,
  lib,
  sources,
}@args:
{
  nixos = {
    modules.services.marginalia-search = ./module.nix;
    tests.marginalia-search = import ./test.nix args;
    examples = {
      base = {
        description = ''
          A basic configuration of a MySQL database, Zookeeper, and Marginalia.

          This configuration will allow opening the control panel at <http://127.0.0.1:7000>.

          Insecure practices are used here to make testing easy.
          For production usage, look into secrets management via Nix.
        '';
        path = ./example.nix;
      };
    };
  };
}
