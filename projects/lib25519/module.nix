{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.lib25519;
in
{
  options.programs.lib25519 = {
    enable = lib.mkEnableOption "lib25519";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lib25519
      libcpucycles
      librandombytes
    ];
  };
}
