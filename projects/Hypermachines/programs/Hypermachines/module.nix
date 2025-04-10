{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.Hypermachines;
in
{
  options.programs.Hypermachines = {
    enable = lib.mkEnableOption "Hypermachines";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      autobase
      corestore
      hyperbeam
      hyperblobs
      hypercore
      hyperswarm
    ];
  };
}
