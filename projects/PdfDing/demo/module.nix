{ pkgs, ... }:
{
  services.pdfding = {
    enable = true;
    openFirewall = true;
    secretKeyFile = pkgs.writeText "django_secret" "foobarbaz";
  };
}
