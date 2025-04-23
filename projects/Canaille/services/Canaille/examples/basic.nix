{ ... }:

{
  services.canaille.enable = true;
  services.canaille.settings.SERVER_NAME = "auth.mydomain.example";
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "you@example.com";
  services.canaille.secretKeyFile = "/etc/nixos/canaille-secret.key";
}
