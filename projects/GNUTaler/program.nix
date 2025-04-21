{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.taler;
in
{
  options.programs.taler = {
    enable = lib.mkEnableOption "GNU Taler";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      anastasis
      anastasis-gtk
      libeufin
      taldir
      taler-challenger
      taler-depolymerization
      taler-exchange
      taler-mdb
      taler-merchant
      taler-sync
      taler-wallet-core
      twister
    ];
  };
}
