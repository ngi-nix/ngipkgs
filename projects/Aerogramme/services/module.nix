{ lib, pkgs, ... }:
{
  options.services.aerogramme = {
    enable = lib.mkEnableOption "Aerogramme";
    package = lib.mkPackageOption pkgs "aerogramme" { };
  };
  # TODO: add a service definition
}
