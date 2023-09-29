{
  boot.isContainer = true;
  networking.hostName = "test-flarum";

  # Allow nginx through the firewall
  networking.firewall.allowedTCPPorts = [80];

  services.nginx.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  services.flarum = rec {
    enable = true;
    # domain = "localhost"; # Default, Set this to whatever your local container IP address is
    # baseUrl = "https://{domain}" # Default, if you need http override manually
  };
}
