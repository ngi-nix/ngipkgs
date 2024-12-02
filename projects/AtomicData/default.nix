{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs)
      atomic-server
      atomic-browser
      atomic-cli
      ;
  };
  nixos = {
    modules.services.atomic-server = ./service.nix;
    examples = {
      base = {
        path = ./example.nix;
        description = "Basic configuration, mainly used for testing purposes.";
      };
    };
    tests.atomic-server = import ./test.nix args;
  };
}
