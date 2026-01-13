{ lib }:
lib.composeManyExtensions [
  (import nixos/systemd.nix { inherit lib; })
]
