{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.keyoxide-cli;
in
{
  options.programs.keyoxide-cli = {
    enable = lib.mkEnableOption "keyoxide-cli";
    package = lib.mkPackageOption pkgs "keyoxide-cli" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
