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
    # WARNING: handling passwords in plaintext is not secure in production and
    # is merely used for illustrative purposes, here.
    initialScript = pkgs.writeText "postgresql-password" ''
      CREATE ROLE sstoryline WITH LOGIN PASSWORD 'sst_1234' CREATEDB;
    '';
  };

  # make sure SSToryTime only starts after the database has been initialized
  systemd.services.sstorytime.requires = [ "postgresql.target" ];
  systemd.services.sstorytime.after = [ "postgresql.target" ];
}
