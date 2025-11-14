{ pkgs, ... }:
{
  networking.domain = "localdomain";
  services.bonfire = {
    enable = true;
    settings = {
      HOSTNAME = "localhost";
      PUBLIC_PORT = 80;
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
  services.meilisearch.masterKeyFile = pkgs.writeText "meilisearch.masterKeyFile" "675b2c63f569d0bb3f872517b903fa9ea3ddce19d5766c80a8";
}
