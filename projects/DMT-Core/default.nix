{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs.python3Packages) dmt-core;
  };
}
