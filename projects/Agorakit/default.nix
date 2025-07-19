{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "A web-based, open source organization tool for collectives";
    subgrants = [
      "Agorakit"
    ];
  };

  nixos = {
    modules.services.agorakit = {
      module = lib.moduleLocFromOptionString "services.agorakit";
      examples.basic.module = null;
    };
    tests.basic.module = pkgs.nixosTests.agorakit;
  };
}
