# https://github.com/NixOS/nixpkgs/blob/f34483be5ee2418a563545a56743b7b59c549935/nixos/tests/web-apps/open-web-calendar.nix
{ lib, ... }:

let
  # required by module, not used
  serverDomain = "open-web-calendar.example.com";
  servicePort = 8080;
in
{
  services.open-web-calendar = {
    enable = true;
    domain = serverDomain;
    calendarSettings.title = "My custom title";
  };

  services.nginx = {
    defaultHTTPListenPort = servicePort;
    virtualHosts."${serverDomain}" = {
      forceSSL = lib.mkForce false;
      enableACME = lib.mkForce false;
    };
  };

  networking.hosts."::1" = [ "${serverDomain}" ];
  networking.firewall.allowedTCPPorts = [ servicePort ];
}
