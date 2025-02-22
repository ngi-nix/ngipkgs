{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) marginalia-search;
  };
  nixos = {
    modules.services.marginalia-search = ./module.nix;
    tests.marginalia-search = import ./test.nix args;
    /*
    examples = {
      base = {
        description = "Basic configuration, mainly used for testing purposes.";
        path = ./example.nix;
      };
    };
    */
  };
}
