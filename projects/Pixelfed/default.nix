{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "ActivityPub-driven decentralised photo sharing platform";
    subgrants = [
      "PixelDroid-MediaEditor"
      "PixelFedLive"
      "Pixelfed"
      "Pixelfed-Groups"
    ];
    links = {
      docs = {
        text = "Documentation";
        url = "https://docs.pixelfed.org/";
      };
    };
  };

  nixos.modules.services = {
    pixelfed = {
      module = lib.moduleLocFromOptionString "services.pixelfed";
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/pixelfed/standard.nix";
      };
    };
  };
}
