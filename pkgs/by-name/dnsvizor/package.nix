{
  lib,
  fetchFromGitHub,
  pkgsStatic,
  stdenv,
  callPackage,
  ...
}:
let
  libMirage = callPackage ../../../lib/pkgs/mirage.nix { };

  # Explanation: remove broken targets instead of setting meta.broken
  # because it doesn't cover eval failure by IFD.
  # For more detailed support state, see: https://github.com/Solo5/solo5/blob/dabc69fd89b8119449ec4088c54b458d4ccc851b/docs/building.md?plain=1#L55
  targets = lib.subtractLists (
    [
      "macosx"
      "genode" # Explanation: removed in solo5 0.7.0
    ]
    ++ lib.optionals stdenv.hostPlatform.isAarch64 [
      "xen"
      "qubes"
      "virtio"
      "muen"
    ]
  ) libMirage.possibleTargets;
in

lib.genAttrs targets (
  target:
  libMirage.build {
    pname = "dnsvizor";
    version = "0-unstable-2025-12-17";
    inherit target;
    src = fetchFromGitHub {
      owner = "robur-coop";
      repo = "dnsvizor";
      rev = "57dbfa7208c765ba531995d9638f4a68b4cc6c15";
      hash = "sha256-heiCAB+1TlAVa23r1GD6WP2w3Ha8kbqKup/gzJz0EW8=";
      # ideally we should use postPatch, but we cannot
      postFetch = ''
        # TODO(linj) enable test
        # currently tests fail to build if target is not "unix"
        rm -vrf $out/test

        # TODO(linj) remove this patch after dnsvizor#114 is merged
        substituteInPlace $out/config.ml --replace-fail \
          'package ~min:"0.5.0" "metrics";' \
          'package ~min:"0.5.0" "metrics"; package ~min:"0.5.0" "metrics-lwt";'
      '';
    };
    depexts = [
      pkgsStatic.gmp # some targets, such as hvt, need static gmp
    ];
    monorepoQuery = {
      uutf = "1.0.3+dune"; # default version is not in the dune overlay yet
    };
    query = {
      # follow upstream CI version (.cirrus.yml) because newer ones fail to build
      ocaml-base-compiler = "4.14.2";
    };
  }
)
