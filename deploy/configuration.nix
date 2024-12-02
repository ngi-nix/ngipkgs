{
  config,
  pkgs,
  ...
}:
{
  # For more info: https://github.com/ngi-nix/ngipkgs/blob/main/maintainers/cachix.md
  nix.settings.substituters = [ "https://ngi.cachix.org/" ];
  nix.settings.trusted-public-keys = [
    "ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw="
  ];

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "pass";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "24.11";
}
