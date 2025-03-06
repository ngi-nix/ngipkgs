{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs)
      anastasis
      anastasis-gtk
      libeufin
      taldir
      taler-depolymerization
      taler-exchange
      taler-mdb
      taler-merchant
      taler-sync
      taler-wallet-core
      twister
      ;
  };
  nixos = {
    # TODO: add modules once https://github.com/NixOS/nixpkgs/pull/332699 is merged
    modules.services = null;
    # TODO: move test in pkgs/by-name/anastasis/test.nix into project directory
    tests = null;
    examples = null;
  };
}
