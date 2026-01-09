{
  lib,
  hillingar,
  fetchFromGitHub,
  pkgsStatic,
  stdenv,
}:

let
  version = "0-unstable-2025-12-17";

  unikernel =
    lib.flip hillingar.mkUnikernelPackages
      (fetchFromGitHub {
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
      })
      {
        unikernelName = "dnsvizor";
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
      };

  targets = [
    "unix"
    "hvt"
    "spt"
    "xen"
    "qubes"
    "virtio"
    "muen"
    "macosx"
    "genode"
  ];

  # not use lib.isDerivation because it triggers IFD error if there is one
  isDerivation = target: _package: lib.elem target targets;

  # bad: eval failure by IFD or build failure
  # do not use/set meta.broken because it doesn't cover eval failure by IFD
  # more detailed support state can be found in https://github.com/Solo5/solo5/blob/dabc69fd89b8119449ec4088c54b458d4ccc851b/docs/building.md?plain=1#L55
  knownBad =
    target:
    (lib.elem target [
      "macosx"
      "genode" # removed in solo5 0.7.0
    ])
    || (
      stdenv.hostPlatform.isAarch64
      && lib.elem target [
        "xen"
        "qubes"
        "virtio"
        "muen"
      ]
    );
  notKnownBad = target: _package: !(knownBad target);

  # This project has no release so the inferred version is "dev", which is invalid for nix.
  # Use this function to make it valid when necessary.
  overrideVersionIfDev =
    newVersion: package:
    package.overrideAttrs (old: {
      version = if old.version == "dev" then newVersion else old.version;
      __intentionallyOverridingVersion = true;
    });
in
lib.pipe unikernel [
  (lib.filterAttrs isDerivation)
  (lib.filterAttrs notKnownBad)
  (lib.mapAttrs (_target: package: overrideVersionIfDev version package))
]
