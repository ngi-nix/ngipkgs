{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) librecast lcrq lcsync;
  };
}
