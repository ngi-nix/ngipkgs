{ config, pkgs, ... }:
let
  kazarmaCfg = config.services.kazarma.settings;
  # https://docs.kazar.ma/administrator-guide/erlang-release#configure
  # openssl rand -hex 64
  ACCESS_TOKEN = "4f85399b28b835cbd031e8cafb4b30e89cb2462df0aac15024b1e4d0bc75a656f1388a5b61103dec7dac80081b71a18bfe16b4f6c90238d3c9a22bd56e433d32";
  HOMESERVER_TOKEN = "e830634167755875c63f92bf33558e0a25f9b57ab8e8d9810ecf1d8c02c6e9f8bb928541fb122ac78e8d9673a923eead7d22c7fe826c86689deba58c227fa3d7";
  SECRET_KEY_BASE = "69c359e216fc4bde402905cdcae0b86bfe3ad16277d40241fe2afcdfb991fa6996424970b12ffd877e5263148bbf275d8520bcf692a3741a6d858ca6e9f5087b";
in
{
  services.kazarma = {
    enable = true;
    settings = {
      RELEASE_COOKIE = "CDODIMOGYEETMVEJAAFQNXNQ7RE6VWBVD4IGN5GTAA6U4WPNVFPQ====";
      inherit ACCESS_TOKEN HOMESERVER_TOKEN SECRET_KEY_BASE;
    };
  };
  systemd.services.kazarma = {
    requires = [
      "postgresql.target"
      "matrix-synapse.service"
      "honk.service"
    ];
    after = [
      "postgresql.target"
      "matrix-synapse.service"
      "honk.service"
    ];
  };

  services.postgresql = {
    enable = true;
    initialScript =
      let
        synapseDbCfg = config.services.matrix-synapse.settings.database.args;
      in
      pkgs.writeText "init-sql-script" ''
        CREATE ROLE "${kazarmaCfg.DATABASE_USERNAME}" LOGIN PASSWORD '${kazarmaCfg.DATABASE_PASSWORD}';
        CREATE DATABASE "${kazarmaCfg.DATABASE_DB}" OWNER "${kazarmaCfg.DATABASE_USERNAME}";

        CREATE ROLE "${synapseDbCfg.user}" LOGIN PASSWORD '${synapseDbCfg.password}';
        CREATE DATABASE "${synapseDbCfg.database}" OWNER "${synapseDbCfg.user}"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
  };

  # ActivityPub server
  services.honk = {
    enable = true;
    username = "username";
    servername = "servername";
    passwordFile = pkgs.writeText ''honk-password'' "password";
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      database = {
        name = "psycopg2";
        args.password = "matrix-synapse";
      };
      app_service_config_files = [
        # https://docs.kazar.ma/administrator-guide/homeserver-configuration
        (pkgs.writeText "kazarma.yaml" (
          builtins.toJSON {
            id = "Kazarma";
            url = "http://${kazarmaCfg.HOST}:${kazarmaCfg.PORT}/matrix/";
            as_token = ACCESS_TOKEN;
            hs_token = HOMESERVER_TOKEN;
            sender_localpart = "_kazarma";
            namespaces = {
              aliases = [
                {
                  exclusive = true;
                  regex = "#_ap_.+___.+";
                }
              ];
              users = [
                {
                  exclusive = true;
                  regex = "@_ap_.+___.+";
                }
              ];
            };
          }
        ))
      ];
    };
  };
}
