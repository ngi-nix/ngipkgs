{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.openxc7;
in
{
  options.programs.openxc7 = {
    enable = lib.mkEnableOption "openXC7 environment";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ openxc7 ];
  };
}
