{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open, decentralised platform for 3D assets";
    subgrants = {
      Commons = [
        "Icosa-Gallery"
      ];
      Entrust = [
        "IcosaGallery"
      ];
    };
    links = {
      website = {
        text = "Website";
        url = "https://icosa.gallery/";
      };
      docs = {
        text = "Documentation";
        url = "https://api.icosa.gallery/v1/docs";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/icosa-foundation/icosa-gallery";
      };
    };
  };

  nixos.modules.services.icosa-gallery = {
    name = "icosa-gallery";
    module = ./services/icosa-gallery/module.nix;
    examples."Enable icosa-gallery" = {
      module = ./services/icosa-gallery/examples/basic.nix;
      description = null;
      tests.basic.module = import ./services/icosa-gallery/tests/basic.nix args;
    };
  };
}
