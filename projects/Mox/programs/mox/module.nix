{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.mox;
in
{
  options.programs.mox = {
    enable = lib.mkEnableOption "mox";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mox
    ];
  };
}
