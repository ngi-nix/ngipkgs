{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) openfire;
  };
  nixos = {
    modules.services.openfire-server = ./service.nix;
    examples = {
      base = {
        path = ./example.nix;
        description = "Basic configuration, mainly used for testing purposes.";
      };
    };
    tests.openfire-server = import ./test.nix args;
  };
}
