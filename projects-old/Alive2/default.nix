{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) alive2;
  };
}
