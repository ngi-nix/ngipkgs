{ lib, pkgs, ... }:
{
  options.services.aerogramme = {
    enable = lib.mkEnableOption "Aerogramme";
    package = lib.mkPackageOption pkgs "aerogramme" { };
  };
  # TODO: add a service definition
  # FIX: figure out how to express that something doesn't work as intended yet
  # meta.broken = true;
}
