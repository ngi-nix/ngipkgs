{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = ["mcaptcha" "mcaptcha-cache"];
  nixos = {
    modules.services.mcaptcha = ./service.nix;
    tests = {
      create-locally = import ./tests/create-locally.nix args;
      bring-your-own-services = import ./tests/bring-your-own-services.nix args;
    };
  };
}
