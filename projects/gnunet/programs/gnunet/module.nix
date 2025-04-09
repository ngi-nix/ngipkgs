{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gnunet;
in
{
  options.programs.gnunet = {
    enable = lib.mkEnableOption "gnunet";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnunet
      gnunet-gtk
      gnunet-messenger-cli
      libgnurl
    ];
  };
}
