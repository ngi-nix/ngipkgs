{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };

  users.users.root = {
    initialPassword = "root";
  };

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "nixos";
}
