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
      # either use smtp.createLocally or specify a valid account on your mail provider.
      user = "weblate@example.org";
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
