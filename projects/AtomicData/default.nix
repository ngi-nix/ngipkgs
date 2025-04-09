{ pkgs, ... }@args:
{
  nixos = {
    modules.services.atomic-server = {
      module = ./service.nix;
      examples.base = {
        module = ./example.nix;
        description = "Basic configuration, mainly used for testing purposes.";
        tests.atomic-server = import ./test.nix args;
      };
    };
  };
}
