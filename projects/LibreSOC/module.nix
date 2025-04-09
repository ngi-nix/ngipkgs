{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.libresoc;
in
{
  options.programs.libresoc = {
    enable = lib.mkEnableOption "libresoc";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libresoc-nmigen
    ];
  };
}
