{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "ActivityPub-powered tool for storing and sharing 3d models";
    subgrants = [
      "Manyfold-Discovery"
      "Personal-3D-archive"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://manyfold.app/";
      };
      src = {
        text = "Source code";
        url = "https://github.com/manyfold3d/manyfold";
      };
      example = {
        text = "Usage examples";
        url = "https://manyfold.app/get-started/installation";
      };
    };
  };

  nixos.modules.services.manyfold = {
    name = "Manyfold";
    module = ./services/manyfold/module.nix;
    examples."Enable Manyfold" = {
      module = ./services/manyfold/examples/basic.nix;
      description = null;
      tests.basic.module = null;
    };
  };
}
