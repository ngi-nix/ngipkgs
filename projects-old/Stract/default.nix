{ pkgs, ... }@args:
{
  packages = { inherit (pkgs) stract; };
}
