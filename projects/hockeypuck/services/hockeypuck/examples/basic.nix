{ ... }:

{
  services.hockeypuck.enable = true;

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hockeypuck" ];
    ensureUsers = [
      {
        name = "hockeypuck";
        ensureDBOwnership = true;
      }
    ];
  };
}
