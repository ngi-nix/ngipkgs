{ ... }:

{
  services.mox.enable = true;
  services.mox.hostname = "mail";
  services.mox.user = "admin@example.com";
  services.mox.openFirewall = true;
  services.mox.openPorts = [
    25
    80
    443
  ];
}
