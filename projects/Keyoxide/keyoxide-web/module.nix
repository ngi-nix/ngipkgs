{
  lib,
  pkgs,
  ...
}:
{
  options.services.keyoxide = {
    enable = lib.mkEnableOption "keyoxide-web";
    package = lib.mkPackageOption pkgs "nodePackages.keyoxide" { };
  };
}
