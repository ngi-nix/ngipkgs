{
  config,
  lib,
  pkgs,
  ...
}:
{

  services.mobilizon = {
    enable = true;
    settings =
      let
        # These are helper functions, that allow us to use all the features of the Mix configuration language.
        # - mkAtom and mkRaw both produce "raw" strings, which are not enclosed by quotes.
        # - mkGetEnv allows for convenient calls to System.get_env/2
        inherit ((pkgs.formats.elixirConf { }).lib) mkAtom mkRaw mkGetEnv;
      in
      {
        ":mobilizon" = {

          # General information about the instance
          ":instance" = {
            name = "My mobilizon instance";
            description = "A descriptive text that is going to be shown on the start page.";
            hostname = "your-mobilizon-domain.com";
            email_from = "mail@your-mobilizon-domain.com";
            email_reply_to = "mail@your-mobilizon-domain.com";
          };

          # SMTP configuration
          "Mobilizon.Web.Email.Mailer" = {
            adapter = mkAtom "Swoosh.Adapters.SMTP";
            relay = "your.smtp.server";
            # usually 25, 465 or 587
            port = 587;
            username = "mail@your-mobilizon-domain.com";
            # See "Providing a SMTP password" below
            password = mkGetEnv { envVariable = "SMTP_PASSWORD"; };
            tls = mkAtom ":always";
            allowed_tls_versions = [
              (mkAtom ":tlsv1")
              (mkAtom ":\"tlsv1.1\"")
              (mkAtom ":\"tlsv1.2\"")
            ];
            retries = 1;
            no_mx_lookups = false;
            auth = mkAtom ":always";
          };

        };
      };
  };

  systemd.services.mobilizon.serviceConfig.ImportCredential = [ "mobilizon.SMTP_PASSWORD" ];

  # WARN: !! Don't use this in production !!
  # Instead, put the secrets directly in the systemd credentials store (`/etc/credstore/`, `/run/credstore/`, ...)
  # For more information on this topic, see: <https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#ImportCredential=GLOB>
  environment.etc."credstore/mobilizon.SMTP_PASSWORD".text = "yoursupersecretpassword";

  # In order for Nginx to be publicly accessible, the firewall needs to be configured.
  networking.firewall.allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
  ];

  # For using the Let's Encrypt TLS certificates for HTTPS,
  # you have to accept their TOS and supply an email address.
  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@your-mobilizon-domain.com";
  };
}
