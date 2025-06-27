{
  lib,
  ...
}:
{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = lib.mkDefault "nixos";
}
