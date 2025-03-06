{ pkgs, ... }@args:
{
  packages = { inherit (pkgs) servo; };
}
