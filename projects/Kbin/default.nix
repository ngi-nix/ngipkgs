{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) kbin kbin-frontend kbin-backend;};
  nixos = {
    modules.service = ./service.nix;
    configurations = {
      base = {
        path = ./configuration.nix;
        description = "Basic configuration, mainly used for testing purposes.";
      };
    };
    tests.kbin = import ./test.nix args;
  };
}
