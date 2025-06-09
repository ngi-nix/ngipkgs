{
  imports = [
    ./services.nix
    ./users.nix
    ./virtualisation.nix
  ];

  services.getty.helpLine = ''

    Welcome to NGIpkgs!
  '';

  system.stateVersion = "25.05";
}
