{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wireguard;
in
{
  options.programs.wireguard = {
    enable = lib.mkEnableOption "wireguard";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wireguard-go
      wireguard-rs
      wireguard-tools
    ];
  };
}
