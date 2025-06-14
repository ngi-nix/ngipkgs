{
  config,
  pkgs,
  ...
}:
let
  # !!! THIS IS INSECURE, DO NOT DO THIS IN PRODUCTION !!!
  # This is only done like this here to allow easy testing & debugging.
  # Use some secrets management mechanism to track values like this outside of Nix, so they can't leak into the store
  couchdbUser = "inventaire";
  couchdbPassword = "ThisIsNotSecurelyManagedAndImFullyAwareOfThis";
  couchdbPort = 5984;
  elasticPort = 9200;
in
{
  # !!! THIS IS INSECURE, DO NOT DO THIS IN PRODUCTION !!!
  # This is just done like this here to allow easy testing & debugging.
  # Use some secrets management mechanism to get a string of a path at runtime here.
  environment.etc."inventaire-config-overrides.cjs".text = ''
    // This is not securely managed, and I'm fully aware of this.

    module.exports = {
      db: {
        hostname: "localhost",
        port: ${toString couchdbPort},
        username: "${couchdbUser}",
        password: "${couchdbPassword}",
      },
      elasticsearch: {
        origin: "http://localhost:${toString elasticPort}",
      },
      mediaStorage: {
        local: {
          folder: "${config.services.inventaire.stateDir}/storage",
        },
      },
    }
  '';

  services.couchdb = {
    enable = true;
    port = couchdbPort;

    extraConfigFiles = [
      # !!! THIS IS INSECURE, DO NOT DO THIS IN PRODUCTION !!!
      # This is only done like this here to allow easy testing & debugging.
      # Point it at a path that secrets management will produce at runtime instead.
      ((pkgs.formats.ini { }).generate "couchdb-admin-setup.ini" {
        admins = {
          "${couchdbUser}" = "${couchdbPassword}";
        };
      })
    ];
  };

  # !!! THIS IS INSECURE, DO NOT DO THIS IN PRODUCTION !!!
  # This is only done like this here to allow easy testing & debugging.
  # Manually complete the CouchDB setup instead.
  systemd.services."couchdb-setup" = {
    description = "Setup of CouchDB";

    wantedBy = [
      "couchdb.service"
      "inventaire.service"
    ];
    after = [ "couchdb.service" ];
    before = [ "inventaire.service" ];

    path = with pkgs; [
      bash
      coreutils
      curl
      netcat
    ];

    serviceConfig.Type = "oneshot";

    script = ''
      set -e

      echo "Waiting for CouchDB to open its port..."
      timeout 30 bash -c 'until nc -z localhost ${toString config.services.couchdb.port}; do sleep 1; done'
      echo "CouchDB port open."

      echo "Creating _user table in CouchDB (if necessary)..."
      set +x # in case it already exists
      curl -X PUT \
        'http://${couchdbUser}:${couchdbPassword}@localhost:${toString config.services.couchdb.port}/_users'
      set -e
      echo "_user table created."

      echo "CouchDB should now be configured for Inventaire usage."
    '';
  };

  services.elasticsearch = {
    enable = true;
    port = elasticPort;
  };

  services.inventaire = {
    enable = true;
    # When using proper secrets management, set a path produced at runtime by your secrets management here instead.
    configOverridesFile = "/etc/inventaire-config-overrides.cjs";
  };

  # We connect to local instances of these, so we might as well ensure they get launched first
  systemd.services."inventaire".wants = [
    "couchdb.service"
    "elasticsearch.service"
  ];
  systemd.services."inventaire".after = [
    "couchdb.service"
    "elasticsearch.service"
  ];
}
