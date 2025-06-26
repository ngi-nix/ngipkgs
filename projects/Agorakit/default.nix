{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    subgrants = [
      "Agorakit"
    ];
  };

  nixos = {
    modules.services.agorakit = {
      module = lib.moduleLocFromOptionString "services.agorakit";
      examples.basic.module = null;
    };
    tests.basic = pkgs.nixosTests.agorakit;
  };
}
