# https://github.com/NixOS/nixpkgs/blob/c7661dfc33f947d81443ec911549e2d0f6414085/nixos/tests/matrix/draupnir.nix
{ ... }:

{
  # We want a server for demos.
  services.matrix-synapse = {
    enable = true;
    log.root.level = "WARNING";
    settings = {
      database.name = "sqlite3";
      # Do *NOT* do this in production!
      registration_shared_secret = "supersecret-registration";

      listeners = [
        {
          bind_addresses = [
            "::"
          ];
          port = 8008;
          resources = [
            {
              compress = true;
              names = [ "client" ];
            }
            {
              compress = false;
              names = [ "federation" ];
            }
          ];
          tls = false;
          type = "http";
          x_forwarded = false;
        }
      ];
    };
  };

  services.draupnir = {
    enable = true;
    settings = {
      homeserverUrl = "http://localhost:8008";
      managementRoom = "#moderators:homeserver";
    };
    secrets = {
      # This needs be set up before the service is started.
      accessToken = "/tmp/draupnir-access-token";
    };
  };
}
