{ pkgs, ... }@args:
{
  packages = { inherit (pkgs) icestudio; };
}
