{pkgs, ...}: {
  packages = {
    inherit (pkgs) cnsprcy;
  };
  # https://git.sr.ht/~xaos/cnsprcy/tree/master/item/src/config.rs
  nixos.services = null;
  nixos.tests = null;
  nixos.examples = null;
}
