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
    package = lib.mkPackageOption pkgs "_programName_" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
      # put extra `packages` here
    ];
  };
}
