{ lib, config, ... }:
{
  imports = [
    ./services.nix
    ./users.nix
    ./virtualisation.nix
  ];

  # not relevant for our purposes
  documentation.nixos.enable = false;

  services.getty.greetingLine = ''<<< Welcome to NGIpkgs ${config.system.nixos.label} (\m) - \l >>>'';
  services.getty.helpLine = ''

    To exit the demo VM, run: `sudo poweroff`
  '';

  services.xserver = {
    enable = lib.mkDefault false;
    windowManager.icewm.enable = true;
  };
  services.displayManager = {
    defaultSession = lib.mkDefault "none+icewm";
  };

  system.stateVersion = "25.05";
}
