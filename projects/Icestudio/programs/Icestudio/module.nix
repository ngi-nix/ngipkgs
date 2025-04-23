{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.icestudio;
in
{
  options.programs.icestudio = {
    enable = lib.mkEnableOption "icestudio";
  };

  # icestudio depends on nwjs, limited available platforms
  # TODO; adjust icestudio meta.platforms accordingly upstream
  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.nwjs)
        [ pkgs.icestudio ];
  };
}
