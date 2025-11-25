{ pkgs, ... }:

{
  services.sstorytime = {
    enable = true;
    port = 3030;
    openFirewall = true;
    database = {
      # By default, this will create a local database.
      # You can change it to a remote host or unix socket.
      host = "localhost";
      dbname = "sstoryline";
      user = "sstoryline";
      # WARNING: ! Don't use this in production !
      # Use a proper secret-management solution like `sops` or `agenix`.
      passwordFile = pkgs.writeText "database-secret" "sst_1234";
    };
  };
}
