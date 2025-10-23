{ lib, ... }:
{
  services.openssh = {
    enable = true;
    ports = [
      10022
    ];
    settings = {
      PasswordAuthentication = true;
      PermitEmptyPasswords = "yes";
      PermitRootLogin = "yes";
    };
  };

  networking.firewall.enable = lib.mkDefault false;
}
