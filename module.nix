{ config, lib, pkgs, ... }:

let
  cfg = config.services.weblate;

in
{

  options = {
    services.weblate = {
      enable = lib.mkEnableOption "Weblate service";

      localDomain = lib.mkOption {
        description = "The domain serving your Weblate instance.";
        example = "weblate.example.org";
        type = lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];

    systemd.services.weblate = {
      after = [ "network.target" "postgresql.service" ];
      description = "Weblate";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "";
        Restart = "always";
        RestartSec = 20;
        WorkingDirectory = pkgs.weblate;
        RuntimeDirectory = "weblate";
        RuntimeDirectoryMode = "0750"; # ?
        # System Call Filtering
        # SystemCallFilter = "~" + lib.concatStringsSep " " (systemCallsList ++ [ "@resources" ]);
      };
      path = with pkgs; [ git ];
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true; # required for redirections to work
      virtualHosts."${cfg.localDomain}" = {

        forceSSL = true;
        enableACME = true;

        locations = {
          "= /favicon.ico".alias = "${pkgs.weblate}/lib/${pkgs.python.libPrefix}/site-packages/weblate/static/favicon.ico";
          "/static/".alias = "/var/lib/weblate/static/";
          "/media/".alias = "/var/lib/weblate/media/";
          "/".extraConfig = ''
            include uwsgi_params;
            # Needed for long running operations in admin interface
            uwsgi_read_timeout 3600;
            # Adjust based to uwsgi configuration:
            uwsgi_pass unix:///run/uwsgi/app/weblate/socket;
            # uwsgi_pass 127.0.0.1:8080;
          '';
        };

      };
    };

    services.postfix = {
      enable = true;
    };
    services.redis = {
      enable = true;
    };
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "weblate";
          ensurePermissions."DATABASE weblate" = "ALL PRIVILEGES";
        }
      ];
      ensureDatabases = [ "weblate" ];
    };

    users.users.weblate = {
      isSystemUser = true;
    };

    users.groups.weblate.members = [ config.services.nginx.user ];
  };

  meta.maintainers = with lib.maintainers; [ erictapen ];

}
