{ lib, ... }:
{
  disabledModules = [
    "services/networking/wireguard.nix"
  ];

  imports = [
    ./wireguard.nix
  ];
}

