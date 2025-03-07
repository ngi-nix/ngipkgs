{
  lib,
  pkgs,
  sources,
}@args:
{
  module =
    { lib, pkgs, ... }:
    {
      options.programs.keyoxide = {
        enable = lib.mkEnableOption "keyoxide-cli";
        package = lib.mkPackageOption pkgs "nodePackages.keyoxide" { };
      };
    };
  examples.keyoxide-cli = {
    module = ./example.nix;
    description = "";
    tests.keyoxide-cli = import ./test.nix args;
  };
}
