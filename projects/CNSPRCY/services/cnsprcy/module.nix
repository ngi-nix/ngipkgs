{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cnsprcy;
  libDir = "/var/lib/cnsprcy";
in
{
  options.services.cnsprcy = {
    enable = lib.mkEnableOption "cnsprcy";

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of CNSPRCY server";
      default = "machine1";
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

    environment.systemPackages = with pkgs; [
      cnsprcy
    ];

    # set directory
    # set machine name
    # then in test: set interfaces, add "peers" or whatever, and try and send a msg? 

    users.users."${cfg.user}" = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups."${cfg.group}" = { };

    systemd.tmpfiles.rules = [
      # `cnspr config init` seems to expect the datadir at $HOME/.local/share/cnsprcy for now
      # also i couldnt get this to work with user/group set to cnsprcy - it always set to root
      "d ${libDir}/.local/share/cnsprcy 0750 cnsprcy cnsprcy -"
      "d ${libDir}/.local/share/cnsprcy/handlers 0750 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.cnsprcy = {
      description = "CNSPRCY service";
      wantedBy = [ "multi-user.target" ];
      #after = [ "network.target" ];
      after = [ "nss-user-lookup.target" ];
      # preStart = "whoami && printf 'n\n${cfg.hostname}\n' | ${pkgs.cnsprcy}/bin/cnspr config init "; # how to set machien name
      preStart = ''
        whoami
        printf 'n\n${cfg.hostname}\ny\n' | ${pkgs.cnsprcy}/bin/cnspr config init 
        mkdir ${libDir}/.local/share/cnsprcy/handlers
      '';
      serviceConfig = {
        ExecStart = "${pkgs.cnsprcy}/bin/cnspr serve";
        Restart = "on-failure";
      };
     # environment = {
     #   CNSPRCY_CFG = "${libDir}/cnsprcy.tml";
     # };
    };

  };
}
