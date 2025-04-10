{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kbin;
in
{
  options.programs.kbin = {
    enable = lib.mkEnableOption "kbin";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kbin
      kbin-frontend
      kbin-backend
    ];
  };
}
