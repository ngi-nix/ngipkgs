{ ... }:
{
  services.openfire-server = {
    enable = true;
    openFirewall = true;
    servicePort = 9090;
    securePort = 9191;

    # Settings to be configured on first startup.
    # For available options, see:
    # https://download.igniterealtime.org/openfire/docs/latest/documentation/install-guide.html#Autosetup
    settings.jive.autosetup = {
      run = true;
    };
  };
}
