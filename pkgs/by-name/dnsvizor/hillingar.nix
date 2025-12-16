{
  lib,
  hillingar,
  fetchFromGitHub,
  pkgsStatic,
  stdenv,
}:

let
  version = "0-unstable-2025-12-15";

  unikernel =
    lib.flip hillingar.mkUnikernelPackages
      (fetchFromGitHub {
        # owner = "robur-coop";
        # TODO(linj) handle my patches properly
        #   - upstream them to dnsvizor
        #   - convert them arguments of mkUnikernelPackages: query, monorepoQuery
        owner = "linj-fork";
        repo = "dnsvizor";
        rev = "8b5281ebfdbd3eb0784f5ffdf145d955c438a634";
        hash = "sha256-RyqSTxlJOMKQcZscH/ZcE5zuDYCsoHpr0f+cftMgc/I=";
        # TODO(linj) enable test
        # currently tests fail to build if target is not "unix"
        postFetch = ''
          rm -vrf $out/test
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
  knownBad =
    target:
    (lib.elem target [
      "macosx"
      "genode"
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
