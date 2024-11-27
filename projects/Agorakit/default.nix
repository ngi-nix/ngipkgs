{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) agorakit;
  };
  nixos = {
    modules.services.agorakit = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/agorakit.nix";
    tests.basic = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/agorakit.nix";
    examples = null;
  };
}
