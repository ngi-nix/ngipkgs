{ pkgs, ... }:
{
  services.pdfding = {
    enable = true;
    openFirewall = true;
    # NOTE: this is just for demo purposes
    # you shoud not use this in production, use a secret management tool like sops-nix instead.
    # see https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes for other alternatives.
    secretKeyFile = pkgs.writeText "django_secret" "foobarbaz";
    consume.enable = true; # allows bulk importing pdf files
    consume.schedule = "*/1 * * * *"; # once every minute
  };
}
