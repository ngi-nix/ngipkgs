{
  boot.isContainer = true;
  networking.hostName = "test-flarum";

  # Allow nginx through the firewall
  networking.firewall.allowedTCPPorts = [80];

  services.nginx.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  services.flarum = {
    enable = true;
    domain = "10.233.2.2";
  };
}
