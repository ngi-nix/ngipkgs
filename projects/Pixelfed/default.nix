{
  lib,
  pkgs,
  sources,
  system,
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
        # aarch64 is not a supported platform for the test
        tests.basic = if (system != "aarch64-linux") then pkgs.nixosTests.pixelfed.standard else null;
      };
    };
  };
}
