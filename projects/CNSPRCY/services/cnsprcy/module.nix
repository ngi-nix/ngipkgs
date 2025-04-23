{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cnsprcy;
in
{
  options.services.cnsprcy = {
    enable = lib.mkEnableOption "cnsprcy";
  };

  config = lib.mkIf cfg.enable {

    systemd.services.cnsprcy = {
      script = ''
        ${pkgs.cnsprcy}/bin/cnspr serve
      '';
    };

  };
}
