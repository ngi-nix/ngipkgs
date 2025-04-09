{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.scion;
in
{
  options.programs.scion = {
    enable = lib.mkEnableOption "scion";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      scion
      scion-apps
      scion-bootstrapper
      ioq3-scion
      pan-bindings
    ];
  };
}
