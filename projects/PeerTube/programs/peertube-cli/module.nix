{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.peertube-cli;
in
{
  options.programs.peertube-cli = {
    enable = lib.mkEnableOption "peertube-cli";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      peertube.cli
    ];
  };
}
