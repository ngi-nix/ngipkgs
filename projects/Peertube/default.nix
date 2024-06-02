{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) peertube peertube-plugin-hello-world;
  };
  nixos = {
    modules.services.peertube.plugins = ./module.nix;
    tests.peertube-plugins = import ./test.nix args;
  };
}
