{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) rosenpass rosenpass-tools;};
  nixos = {
    modules.services.rosenpass = null;
    tests.rosenpass = import ./tests args;
  };
}
