{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.arpa2;
in
{
  options.programs.arpa2 = {
    enable = lib.mkEnableOption "arpa2";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kip
      leaf
      lillydap
      quicksasl
      steamworks
      steamworks-pulleyback
      tlspool
      tlspool-gui
      quickmem
      arpa2cm
      arpa2common
    ];
  };
}
