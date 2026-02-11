{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Standards-compliant open-source IMAP server with server-side encryption";
    subgrants = {
      Commons = [
        "Aerogramme-1.0"
      ];
      Review = [
        "Aerogramme"
      ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://aerogramme.deuxfleurs.fr";
      };
      repo = {
        text = "Source repository";
        url = "https://git.deuxfleurs.fr/Deuxfleurs/aerogramme";
      };
      docs = {
        text = "Using with service managers";
        url = "https://aerogramme.deuxfleurs.fr/documentation/cookbook/service-manager";
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
