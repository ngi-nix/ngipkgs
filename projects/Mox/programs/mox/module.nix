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
  options.programs._programName_ = {
    enable = lib.mkEnableOption "mox";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mox
    ];
  };
}
