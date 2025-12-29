{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Owncast is an open source, self-hosted, decentralized, single user live video streaming and chat server";
    subgrants.Review = [
      "Owncast"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/owncast/owncast";
      };
      homepage = {
        text = "Homepage";
        url = "https://owncast.online/";
      };
      docs = {
        text = "Documentation";
        url = "https://owncast.online/docs/";
      };
    };
  };

  nixos.modules.services = {
    owncast = {
      module = lib.moduleLocFromOptionString "services.owncast";
      examples."Enable owncast" = {
        module = ./services/owncast/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.owncast;
      };
    };
  };
}
