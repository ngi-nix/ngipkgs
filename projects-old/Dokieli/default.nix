{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) dokieli;
  };
}
