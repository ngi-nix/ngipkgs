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
      examples.basic = null;
    };
    tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/web-apps/agorakit.nix" args;
  };
}
