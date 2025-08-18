{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Standards-compliant open-source IMAP server with server-side encryption";
    subgrants = [
      "Aerogramme"
    ];
    links = {
      config = {
        text = "Configuration reference";
        url = "https://aerogramme.deuxfleurs.fr/documentation/reference/config/";
      };
      service-manager = {
        text = "Using with service managers";
        url = "https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager/";
      };
      nixpkgs = {
        text = "Nixpkgs derivation";
        url = "https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/by-name/ae/aerogramme/package.nix";
      };
    };
  };

  nixos.modules.services = {
    aerogramme = {
      module = ./services/module.nix;
      examples."Enable aerogramme" = {
        module = ./services/examples/basic.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
