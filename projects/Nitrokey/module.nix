{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nitrokey;
in
{
  options.programs.nitrokey = {
    enable = lib.mkEnableOption "nitrokey";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nitrokey-app
      nitrokey-app2
      nitrokey-udev-rules
    ];
  };
}
