{ pkgs, ... }:

{
  services.sstorytime = {
    enable = true;
    port = 3030;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "sstoryline";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "sstoryline" ];
    initialScript = pkgs.writeText "postgresql-password" ''
      CREATE ROLE sstoryline WITH LOGIN PASSWORD 'sst_1234' CREATEDB;
    '';
  };
}
