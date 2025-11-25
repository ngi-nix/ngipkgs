{ pkgs, ... }:

{
  services.sstorytime = {
    enable = true;
    port = 3030;
    openFirewall = true;
    database = {
      createLocally = true;
      dbname = "sstoryline";
      user = "sstoryline";
      # WARNING: ! Don't use this in production !
      # Use a proper secret-management solution like `sops` or `agenix`.
      passwordFile = pkgs.writeText "database-secret" "sst_1234";
    };
  };
}
