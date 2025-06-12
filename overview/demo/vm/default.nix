{
  imports = [
    ./services.nix
    ./users.nix
    ./virtualisation.nix
  ];

  services.getty.helpLine = ''

    Welcome to NGIpkgs!

    - To exit the demo VM, run: `sudo poweroff`
  '';

  system.stateVersion = "25.05";
}
