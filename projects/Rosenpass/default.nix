{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) rosenpass rosenpass-tools;};
  nixos = {
    modules.service.options = "services\\.rosenpass\\..*";
    tests.rosenpass = import ./tests args;
  };
}
