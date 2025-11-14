{ lib }:
# Usage: import directly with:
# ```
# { config, pkgs, …}@args:
# let lib = import path/to/lib/default.nix { inherit (args) lib; }; in
# ```
# Explanation: so that users do not have to `.extend` their `lib` with the present `lib` overlay
# before calling `lib.nixosSystem` (providing `lib` to all modules).
lib.extend (
  lib.composeManyExtensions [
    (import ./nixos.nix { inherit lib; })
  ]
)
