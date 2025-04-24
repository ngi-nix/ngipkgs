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

    environment.systemPackages = with pkgs; [
      cnsprcy
    ];

    systemd.tmpfiles.rules = [
      "d /root/.local/share/cnsprcy 0700 root root -"
      "d /root/.local/share/cnsprcy/handlers 0700 root root -"
    ];

    systemd.services.cnsprcy = {
      description = "CNSPRCY service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      preStart = "${pkgs.cnsprcy}/bin/cnspr config init";
      serviceConfig = {
        ExecStart = "${pkgs.cnsprcy}/bin/cnspr serve";
        Restart = "on-failure";
      };
    };

  };
}
