{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "A web-based, open source organization tool for collectives";
    subgrants.Entrust = [
      "Agorakit"
    ];
    links = {
      homepage = {
        text = "Homepage";
        url = "https://agorakit.org/en";
      };
      repo = {
        text = "Source repository";
        url = "https://github.com/agorakit/agorakit";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.agorakit.org";
      };
    };
  };

  nixos = {
    modules.services.agorakit = {
      module = lib.moduleLocFromOptionString "services.agorakit";
      examples.basic.module = null;
    };
    tests.basic.module = pkgs.nixosTests.agorakit;
  };
}
