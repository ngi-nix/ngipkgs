{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.services.sstorytime;
in
{
  options.services.sstorytime = {
    enable = lib.mkEnableOption "SSTorytime";
    package = lib.mkPackageOption pkgs "sstorytime" { };

    port = mkOption {
      type = types.port;
      description = "Port for the SSTorytime service.";
      default = 8080;
    };

    openFirewall = lib.mkEnableOption "the default ports in the firewall for the SSTorytime server.";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sstorytime = {
      description = "SSTorytime Server";
      serviceConfig = {
        ExecStart = ''
          ${lib.getExe' cfg.package "http_server"}
        '';
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "sstorytime";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      environment.SST_SERVER_PORT = toString cfg.port;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.port
    ];
  };
}
