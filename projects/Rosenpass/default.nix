{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) rosenpass rosenpass-tools;};
  nixos = {
    tests.rosenpass = import ./tests args;
  };
}
