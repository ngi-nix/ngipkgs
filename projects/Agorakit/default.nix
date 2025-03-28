{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    subgrants = [
      "Agorakit"
    ];
  };

  nixos = {
    modules.services.agorakit = {
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/agorakit.nix";
      examples.basic = null;
    };
    tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/web-apps/agorakit.nix" args;
  };
}
