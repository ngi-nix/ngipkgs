{ ... }:

{
  services.owncast = {
    enable = true;
    listen = "0.0.0.0";
    port = 3000;
    openFirewall = true;
    # If you change this, make sure the directory exists with proper ownership
    # and permissions.
    dataDir = "/var/lib/owncast";
  };
}
