{
  pkgs,
  ...
}:

{
  # install tools (N4L, searchN4L, ...)
  programs.sstorytime.enable = true;

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
    # WARNING: hadling passwords in cleartext is not secure in production and
    # is merely used for illustrative purposes, here.
    initialScript = pkgs.writeText "postgresql-password" ''
      CREATE ROLE sstoryline WITH LOGIN PASSWORD 'sst_1234' CREATEDB;
    '';
  };
}
