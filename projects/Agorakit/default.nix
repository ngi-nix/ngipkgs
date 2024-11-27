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
    # TODO: wait for https://github.com/NixOS/nixpkgs/pull/359164 to land in `nixpkgs-unstable`
    # tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/web-apps/agorakit.nix" args;
    examples = null;
  };
}
