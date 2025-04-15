{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.mcaptcha;
in
{
  options.programs.mcaptcha = {
    enable = lib.mkEnableOption "mcaptcha";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mcaptcha
      mcaptcha-cache
    ];
  };
}
