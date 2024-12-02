{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) meta-press;
  };
}
