{
  ...
}:
let
  servicePort = 11371;
in
{
  services.hockeypuck = {
    enable = true;
    port = servicePort;
  };

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

  networking.firewall.allowedTCPPorts = [ servicePort ];
}
