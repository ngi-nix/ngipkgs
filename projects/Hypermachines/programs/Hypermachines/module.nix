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
      # TODO: These have been removed from Nixpkgs because they're nodejs
      # libraries and it wasn't clear how they would be used. See:
      # - https://github.com/NixOS/nixpkgs/pull/403638#issuecomment-3339125475
      # - https://github.com/NixOS/nixpkgs/pull/379542
      #
      # autobase
      # corestore
      # hypercore
      # hyperswarm
      hyperbeam
      hyperblobs
    ];
  };
}
