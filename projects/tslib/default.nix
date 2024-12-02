{ pkgs, ... }:
{
  packages = { inherit (pkgs) tslib; };
}
