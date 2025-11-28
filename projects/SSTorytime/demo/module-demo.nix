{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.sstorytime;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
    ];
  };
}
