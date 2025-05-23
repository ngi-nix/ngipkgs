{ ... }:

{
  services.mox.enable = true;
  services.mox.hostname = "mail";
  services.mox.user = "admin@example.com";
  services.mox.openFirewall = true;
  services.mox.ports.http = 80;
  services.mox.ports.https = 443;
  services.mox.ports.smtp = 25;
}
