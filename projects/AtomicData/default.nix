{ pkgs, ... }@args:
{
  nixos = {
    modules.services.atomic-server = {
      module = ./service.nix;
      examples."Enable Atomic Server" = {
        module = ./example.nix;
        tests.atomic-server.module = import ./test.nix args;
      };
    };
  };
}
