# How to configure database for service

This guide shows how to create a NixOS module that supports both local and remote PostgreSQL databases.

## Simple example: Local database only

For services that only need local database support:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myservice;
  user = "myservice";
  group = "myservice";
in
{
  options.services.myservice = {
    enable = lib.mkEnableOption "My Service";

    database = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "myservice";
        description = "Database name.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [{
        name = user;
        ensureDBOwnership = true;
      }];
    };

    # Application configuration
    systemd.services.myservice = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      requires = [ "postgresql.service" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/myservice";

        # Pass DB config via environment
        Environment = [
          "DB_HOST=/run/postgresql"
          "DB_NAME=${cfg.database.name}"
          "DB_USER=${user}"
        ];
      };
    };

    # Create system user
    users.users."${user}" = {
      isSystemUser = true;
      group = group;
    };
    users.groups."${group}" = {};
  };
}
```

## Advanced example: Local and remote database support

With support of local and remote database option:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myservice;
  user = "myservice";
  group = "myservice";
in
{
  options.services.myservice = {
    enable = lib.mkEnableOption "My Service";

    postgresql = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Create the PostgreSQL database locally.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "myservice";
        description = "Database name.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "myservice";
        description = "Database user. Ignored for local database.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Database host or socket path. Ignored for local database.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5432;
        description = "Database port. Ignored for local database.";
      };

      # Password as string in file
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing the database password.";
        example = "/run/secrets/myservice-db-password";
      };

      # Alternative: .pgpass file format
      # NOTE: Use this as an alternative to the simple passwordFile above
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Password file used for database connection.
          Must be readable only for the service user.

          The file must be a valid `.pgpass` file as described in:
          <https://www.postgresql.org/docs/current/libpq-pgpass.html>

          In most cases, the following will be enough:
          ```
          *:*:*:*:<password>
          ```
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = lib.mkIf cfg.postgresql.createLocally {
      enable = true;
      ensureDatabases = [ cfg.postgresql.name ];
      ensureUsers = [{
        name = user;
        ensureDBOwnership = true;
      }];
    };

    systemd.services.myservice = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ]
        ++ lib.optional cfg.postgresql.createLocally "postgresql.service";
      requires = lib.optional cfg.postgresql.createLocally "postgresql.service";

      preStart = if cfg.postgresql.createLocally
        then ''
          # Socket authentication (local database)
          CONNECTION_STRING="postgresql:///?host=/var/run/postgresql&dbname=${cfg.postgresql.name}"
          ${cfg.package}/bin/myservice-migrate --db "$CONNECTION_STRING"
        ''
        else ''
          # Remote database with password
          DB_PASSWORD=$(cat ${cfg.postgresql.passwordFile})
          CONNECTION_STRING="postgresql://${cfg.postgresql.user}:$DB_PASSWORD@${cfg.postgresql.host}:${toString cfg.postgresql.port}/${cfg.postgresql.name}"
          ${cfg.package}/bin/myservice-migrate --db "$CONNECTION_STRING"
        '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/myservice";
        User = user;
        Group = group;

        # Pass DB config via environment
        Environment = [
          "DB_HOST=${cfg.postgresql.host}"
          "DB_NAME=${cfg.postgresql.name}"
          "DB_USER=${user}"
        ];

        # Load password from credentials directory if using remote database
        LoadCredential = lib.optional (cfg.postgresql.passwordFile != null)
          "db_password:${cfg.postgresql.passwordFile}";
      };
    };

    # Create system user
    users.users."${user}" = lib.mkIf cfg.postgresql.createLocally {
      isSystemUser = true;
      group = group;
    };
    users.groups."${group}" = lib.mkIf cfg.postgresql.createLocally {};
  };
}
```

## Notes

- For local databases, use socket authentication (peer auth) instead of passwords
- If a user needs advanced PostgreSQL configuration, they should not enable the automatic PostgreSQL integration and configure the database themselves

## Links

* [PostgreSQL environment variables]( https://www.postgresql.org/docs/current/libpq-envars.html)
