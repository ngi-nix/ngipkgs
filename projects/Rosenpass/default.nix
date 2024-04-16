{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) rosenpass rosenpass-tools;};
  nixos = {
    modules = {};
    tests.rosenpass = import ./tests args;
  };
}
