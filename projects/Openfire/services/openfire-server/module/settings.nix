{
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    ;
in
# See:
# - https://download.igniterealtime.org/openfire/docs/latest/documentation/install-guide.html#autosetup
# - https://github.com/igniterealtime/Openfire/blob/7693a6f8a19f61b5b026a54fe73f6d735dbe8336/xmppserver/src/main/java/org/jivesoftware/openfire/XMPPServer.java#L432
{
  jive.autosetup = {
    run = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable autosetup feature.";
    };

    locale = mkOption {
      type = types.str;
      default = "en";
      description = "Locale setting.";
    };

    xmpp = {
      domain = mkOption {
        type = types.str;
        default = "server";
        description = "XMPP domain.";
      };
      fqdn = mkOption {
        type = types.str;
        default = "server";
        description = "Fully qualified domain name.";
      };
      auth.anonymous = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable anonymous authentication.";
      };
      socket.ssl.active = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable SSL.";
      };
    };

    encryption = {
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

    database = {
      mode = mkOption {
        type = types.enum [
          "standard"
          "embedded"
        ];
        default = "embedded";
        description = "Database mode.";
      };

      # TODO(@eljamm): non-embedded database setup
      # defaultProvider = {
      #   driver = mkOption {
      #     type = types.str;
      #     default = "org.postgresql.Driver";
      #     description = "Database driver.";
      #   };
      #   serverURL = mkOption {
      #     type = types.str;
      #     default = "jdbc:postgresql://localhost:5432/a-database";
      #     description = "Database server URL.";
      #   };
      #   username = mkOption {
      #     type = types.str;
      #     default = "a-database";
      #     description = "Database username.";
      #   };
      #   password = mkOption {
      #     type = types.str;
      #     default = "a-password";
      #     description = "Database password.";
      #   };
      #   minConnections = mkOption {
      #     type = types.int;
      #     default = 5;
      #     description = "Minimum connections to the database.";
      #   };
      #   maxConnections = mkOption {
      #     type = types.int;
      #     default = 25;
      #     description = "Maximum connections to the database.";
      #   };
      #   connectionTimeout = mkOption {
      #     type = types.float;
      #     default = 1.0;
      #     description = "Timeout for database connections (in seconds).";
      #   };
      # };
    };

    admin = {
      email = mkOption {
        type = types.str;
        default = "admin@example.com";
        description = "Admin email.";
      };
      password = mkOption {
        type = types.str;
        default = "admin";
        description = "Admin password.";
      };
    };

    authprovider.mode = mkOption {
      type = types.str;
      default = "default";
      description = "Authentication provider.";
    };

    users =
      let
        user.options = {
          username = mkOption {
            type = types.str;
            description = "User name.";
          };
          password = mkOption {
            type = types.str;
            description = "User password.";
          };
          name = mkOption {
            type = types.str;
            default = "";
            description = "Display name.";
          };
          email = mkOption {
            type = types.str;
            default = "";
            description = "User email.";
          };
          roster = mkOption {
            type = types.attrs;
            default = { };
            description = "";
          };
        };
      in
      mkOption {
        type = types.attrsOf (types.submodule user);
        default = { };
        description = "User configurations.";
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

        /*
          NOTE: it's necessary that users are defined as increment numbers
          (e.g. user1, user2, ...), else they're not created.
          Instead of enforcing this as a check, we're creating a new attribute
          set to fit this requirement, which arguably provides a better UX.

          ## Example

          ```
          users = { alice = ...; bob = ...; }
          ->
          users = { user1 = ...; user2 = ...; }
          ```
        */
        apply =
          self:
          let
            # sort for consistency since it's not always guarenteed that items
            # will be in the same order.
            sortedUsers = lib.sortOn (x: x.username) (lib.attrValues self);
          in
          lib.listToAttrs (lib.imap1 (i: v: lib.nameValuePair "user${toString i}" v) sortedUsers);
      };
  };

  jive.connectionProvider = {
    className = mkOption {
      type = types.str;
      internal = true;
      default = "org.jivesoftware.database.EmbeddedConnectionProvider";
      description = "Connection provider to the Jive framework.";
    };
  };

  jive.adminConsole = {
    # Some plugins (like restAPI) may need to allow this since they load admin
    # console authentication bypass patterns that includes a wildcard.
    access.allow-wildcards-in-excludes = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow wildcards in excludes.";
    };
    port = mkOption {
      type = types.port;
      default = 9090;
      description = "Insecure admin console port.";
    };
    securePort = mkOption {
      type = types.port;
      default = 9091;
      description = "Secure admin console port.";
    };
    interface = mkOption {
      type = types.str;
      default = "localhost";
      description = "Admin console host.";
    };
  };

  # TODO(@eljamm): only enable if the plugin is included?
  jive.plugin.restapi = {
    enabled = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the RestAPI plugin.";
    };
  };
}
