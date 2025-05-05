{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cnsprcy;
  stateDir = "/var/lib/cnsprcy";
in
{
  options.services.cnsprcy = {
    enable = lib.mkEnableOption "cnsprcy";
    package = lib.mkPackageOption pkgs "cnsprcy" { };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of CNSPRCY server";
      default = builtins.getEnv "HOSTNAME";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "Username of the system user that should own files and services related to CNSPRCY.";
      default = "cnsprcy";
    };
    group = lib.mkOption {
      type = lib.types.str;
      description = "Group that contains the system user that executes CNSPRCY.";
      default = "cnsprcy";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users.users."${cfg.user}" = {
      isSystemUser = true;
      group = cfg.group;

      # CNSPRCY looks for the user home to initialize its data directory
      # at $HOME/.local/share/cnsprcy, but systemd.tmpfiles needs to create
      # the dir otherwise permissions won't be set correctly.
      home = "${stateDir}";
      useDefaultShell = true;
    };
    users.groups."${cfg.group}" = { };

    systemd.tmpfiles.rules = [
      "d ${stateDir}/.local/share/cnsprcy 0700 ${cfg.user} ${cfg.group} -"
      "d ${stateDir}/.local/share/cnsprcy/handlers 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.cnsprcy = {
      description = "CNSPRCY service";
      wantedBy = [ "multi-user.target" ];
      after = [ "nss-user-lookup.target" ];

      # Runs interactive config initialization to set machine name, generate
      # conspirator keys and initial CNSPRCY db
      preStart = "printf 'n\n${cfg.hostname}\ny\n' | ${pkgs.cnsprcy}/bin/cnspr config init";

      serviceConfig = {
        ExecStart = "${pkgs.cnsprcy}/bin/cnspr serve";
        Restart = "on-failure";
        User = "${cfg.user}";
        Group = "${cfg.group}";
      };
    };

  };
}
