{ pkgs, ... }:
{
  packages = {
    inherit (pkgs) cnsprcy;
  };
  nixos = {
    # https://git.sr.ht/~xaos/cnsprcy/tree/master/item/src/config.rs
    modules.services = null;
    tests = null;
    examples = null;
  };
}
