{
  lib,
  pkgs,
  sources,
}@args:
{
  module =
    { lib, pkgs, ... }:
    {
      options.services.keyoxide = {
        enable = lib.mkEnableOption "keyoxide-web";
        package = lib.mkPackageOption pkgs "nodePackages.keyoxide" { };
      };
    };
  links = {
    development = {
      text = "Local development using Nix";
      url = "https://codeberg.org/keyoxide/keyoxide-web#using-nix";
    };
    build = {
      text = "Self-hosting Keyoxide";
      url = "https://docs.keyoxide.org/guides/self-hosting/";
    };
    tests = {
      text = "Test";
      url = "https://codeberg.org/keyoxide/keyoxide-web/src/branch/main/test";
    };
  };
  examples.keyoxide-web = {
    module = ./example.nix;
    description = "";
    tests.keyoxide-web = null;
  };
}
