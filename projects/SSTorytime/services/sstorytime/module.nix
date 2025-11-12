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

    sstConfigDir = mkOption {
      type = types.path;
      description = "Path to the directory containing the SSTconfig files.";
      default = "${cfg.package}/share/config/SSTconfig";
      defaultText = lib.literalExpression "''${pkgs.sstorytime}/share/config/SSTconfig";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      SST_CONFIG_PATH = cfg.sstConfigDir;
    };
    environment.systemPackages = [
      cfg.package
    ];

    systemd.services.sstorytime = {
      description = "SSTorytime Server";
      serviceConfig = {
        ExecStart = ''
          ${lib.getExe' cfg.package "http_server"}
        '';
        DynamicUser = true;
        User = "zwm-server";
        Group = "zwm-server";
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "sstorytime";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      environment.SST_CONFIG_PATH = cfg.sstConfigDir;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };
  };
}
