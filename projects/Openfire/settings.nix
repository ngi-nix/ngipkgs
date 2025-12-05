{
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    ;

  # Define option types
  user.options = {
    username = mkOption {
      type = types.str;
    };
    password = mkOption {
      type = types.str;
    };
    name = mkOption {
      type = types.str;
      default = "";
    };
    email = mkOption {
      type = types.str;
      default = "";
    };
    roster = mkOption {
      type = types.attrs;
      default = { };
    };
  };
in
{
  autosetup.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Enable autosetup feature.";
  };

  autosetup.locale = mkOption {
    type = types.str;
    default = "en";
    description = "Locale setting.";
  };

  autosetup.xmpp = {
    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "XMPP domain.";
    };

    fqdn = mkOption {
      type = types.str;
      default = "localhost";
      description = "Fully qualified domain name.";
    };

    auth = {
      anonymous = mkOption {
        type = types.bool;
        default = true;
        description = "Enable anonymous authentication.";
      };
    };

    socket = {
      ssl = {
        active = mkOption {
          type = types.bool;
          default = true;
          description = "Enable SSL.";
        };
      };
    };
  };

  autosetup.encryption = {
    algorithm = mkOption {
      type = types.str;
      default = "AES";
      description = "Encryption algorithm.";
    };
    key = mkOption {
      type = types.str;
      default = "some-key";
      description = "Encryption key.";
    };
  };

  autosetup.database = {
    mode = mkOption {
      type = types.str;
      default = "standard";
      description = "Database mode.";
    };

    defaultProvider = {
      driver = mkOption {
        type = types.str;
        default = "org.postgresql.Driver";
        description = "Database driver.";
      };

      serverURL = mkOption {
        type = types.str;
        default = "jdbc:postgresql://localhost:5432/a-database";
        description = "Database server URL.";
      };

      username = mkOption {
        type = types.str;
        default = "a-database";
        description = "Database username.";
      };

      password = mkOption {
        type = types.str;
        default = "a-password";
        description = "Database password.";
      };

      minConnections = mkOption {
        type = types.int;
        default = 5;
        description = "Minimum connections to the database.";
      };

      maxConnections = mkOption {
        type = types.int;
        default = 25;
        description = "Maximum connections to the database.";
      };

      connectionTimeout = mkOption {
        type = types.float;
        default = 1.0;
        description = "Timeout for database connections (in seconds).";
      };
    };
  };

  autosetup.admin.email = mkOption {
    type = types.str;
    default = "admin@example.com";
    description = "Admin email.";
  };

  autosetup.admin.password = mkOption {
    type = types.str;
    default = "admin";
    description = "Admin password.";
  };

  autosetup.authprovider.mode = mkOption {
    type = types.str;
    default = "default";
  };

  autosetup.users = mkOption {
    type = types.attrsOf (types.submodule user);
    default = { };
    example = {
      user1 = {
        username = "jane";
        password = "secret";
        name = "Jane Doe";
        email = "user1@example.org";
        roster = [
          {
            jid = "john@example.com";
            nickname = "John";
          }
        ];
      };
    };
    description = "User configurations.";
  };
}
