{
  lib,
  pkgs,
  metrics,
  ...
}@args:
{
  packaging = import ./packaging.nix args;
}
