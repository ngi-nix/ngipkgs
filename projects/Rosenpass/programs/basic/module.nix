{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.rosenpass;
in
{
  options.programs.rosenpass = {
    enable = lib.mkEnableOption "rosenpass";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rosenpass
      rosenpass-tools
    ];
  };
}
