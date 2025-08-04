{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.slipshow;
in
{
  options.programs.slipshow = {
    enable = lib.mkEnableOption "slipshow";
    package = lib.mkPackageOption pkgs "slipshow" { };
    # unfortunately changing the default port is not
    # yet supported
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
