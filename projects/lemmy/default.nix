{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Lemmy is an ActivityPub alternative to Reddit";
    subgrants = {
      Core = [ "Lemmy-Scale" ];
      Entrust = [ "Lemmy-PrivateCommunities" ];
      Review = [
        "Lemmy"
        "LemmyFed-AP"
      ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/LemmyNet/lemmy";
      };
      homepage = {
        text = "Homepage";
        url = "https://join-lemmy.org/";
      };
      docs = {
        text = "Documentation";
        url = "https://join-lemmy.org/docs/";
      };
    };
  };

  nixos.modules.services = {
    lemmy = {
      module = lib.moduleLocFromOptionString "services.lemmy";
      examples."Enable lemmy" = {
        module = ./services/lemmy/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.lemmy;
      };
    };
  };
}
