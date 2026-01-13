{ pkgs, ... }:

{
  networking.domain = "localdomain";
  services.bonfire = {
    enable = true;
    settings = {
      ENCRYPTION_SALT = basic/ENCRYPTION_SALT; # openssl rand -hex 128
      HOSTNAME = "localhost";
      PUBLIC_PORT = 80;
      POSTGRES_PASSWORD = basic/POSTGRES_PASSWORD; # openssl rand -hex 25
      RELEASE_COOKIE = basic/RELEASE_COOKIE; # openssl rand -hex 40
      SECRET_KEY_BASE = basic/SECRET_KEY_BASE; # openssl rand -hex 128
      SIGNING_SALT = basic/SIGNING_SALT; # openssl rand -hex 128
    };
    elixirSettings = {
    };
    postgresql.enable = true;
    meilisearch.enable = true;
    nginx = {
      enable = true;
      virtualHost = {
        serverAliases = [
          "localhost"
          "localhost.localdomain"
        ];
        forceSSL = false;
        enableACME = false;
      };
    };
  };
  services.meilisearch = {
    masterKeyFile = basic/MEILI_MASTER_KEY; # openssl rand -hex 25
  };
}
