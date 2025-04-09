{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs._programName_;
in
{
  options.programs._programName_ = {
    enable = lib.mkEnableOption "_programName_";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # put the `packages` here
    ];
  };
}
