{ pkgs, ... }:
{
  services.pixelfed = {
    enable = true;
    domain = "pixelfed.local";

    # Configure NGINX.
    nginx = { };
    secretFile = (
      pkgs.writeText "secrets.env" ''
        # Snakeoil secret, can be any random 32-chars secret via CSPRNG.
        APP_KEY=adKK9EcY8Hcj3PLU7rzG9rJ6KKTOtYfA
      ''
    );
    settings."FORCE_HTTPS_URLS" = false;
  };
}
