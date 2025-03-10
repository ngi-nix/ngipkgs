{
  lib,
  pkgs,
  sources,
}@args:
{
  module = ./module.nix;
  examples.keyoxide-cli = {
    module = ./example.nix;
    description = "";
    tests.keyoxide-cli = import ./test.nix args;
  };
}
