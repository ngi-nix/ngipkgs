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
    package = lib.mkPackageOption pkgs "cnsprcy" { };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of CNSPRCY server";
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      description = "State directory for CNSPRCY server";
      default = "/var/lib/cnsprcy";
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
      # at $stateDir/.local/share/cnsprcy, but systemd.tmpfiles needs to create
      # the dir otherwise permissions won't be set correctly.
      home = cfg.stateDir;
      useDefaultShell = true;
    };
    users.groups."${cfg.group}" = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}/.local/share/cnsprcy 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.stateDir}/.local/share/cnsprcy/handlers 0700 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.cnsprcy = {
      description = "CNSPRCY service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "nss-user-lookup.target"
        "systemd-tmpfiles-setup.service"
      ];

      # Runs interactive config initialization to set machine name, generate
      # conspirator keys and initial CNSPRCY db. TODO use the config init flags
      # instead, but will need to investigate how to feed args to `cnspr serve`.
      #
      # That said we'll ultimately want to generate the config using options rather
      # than dynamically like this.
      # See https://github.com/ngi-nix/ngipkgs/pull/870#discussion_r2077898766
      preStart = "printf 'n\n${cfg.hostname}\ny\n' | ${lib.getExe cfg.package} config init";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve";
        Restart = "on-failure";
        User = cfg.user;
        Group = cfg.group;
      };
    };

  };
}
