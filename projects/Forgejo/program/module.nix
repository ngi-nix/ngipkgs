{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.forgejo;
in
{
  options.programs.forgejo = {
    enable = lib.mkEnableOption "forgejo";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      forgejo
      forgejo-cli
      forgejo-runner
    ];
  };
}
