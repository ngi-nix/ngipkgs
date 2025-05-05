{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    subgrants = [
      "CNSPRCY"
    ];
  };

  # https://git.sr.ht/~xaos/cnsprcy/tree/master/item/src/config.rs
  nixos.programs.cnsprcy = {
    module = ./module.nix;
    examples.cnsprcy = {
      module = ./example.nix;
      description = "";
      tests.basic = import ./test.nix args;
    };
  };
}
