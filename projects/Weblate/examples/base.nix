{
  config,
  lib,
  pkgs,
  ...
}: {
  services.weblate = {
    enable = true;
    localDomain = "weblate.example.org";
    # Manually deployed secret. Can be generated with
    # `weblate-generate-secret-key > django-secret` when run as the weblate user.
    djangoSecretKeyFile = "/var/lib/weblate/django-secret";
    smtp = {
      enable = true;
      # Specify a valid account and server for your mail provider.
      user = "weblate@example.org";
      host = "mail.example.org";
      # Manually deployed secret
      passwordFile = "/var/lib/weblate/smtp-password";
    };
  };

  # Accept Letsencrypt TOS and provide contact email
  security.acme = {
    defaults.email = "letsencrypt@example.org";
    acceptTerms = true;
  };
}
