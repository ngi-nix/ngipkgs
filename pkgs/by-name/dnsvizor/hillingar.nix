{
  lib,
  hillingar,
  fetchFromGitHub,
  pkgsStatic,
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
        hash = "sha256-Q+g4SO2GDlD2wjz8sjfSEypObpoldkTUMth9RfP1ZdY=";
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

  enabledTargets = [
    "unix"
    "hvt"
    "spt"
    "xen"
    "qubes"
    "virtio"
    "muen"
    # "macosx"
    # "genode"
  ];

  # This project has no release so the inferred version is "dev", which is invalid for nix.
  # Use this function to make it valid when necessary.
  overrideVersionIfDev =
    newVersion: package:
    package.overrideAttrs (old: {
      version = if old.version == "dev" then newVersion else old.version;
      __intentionallyOverridingVersion = true;
    });
in
lib.mapAttrs (_target: package: overrideVersionIfDev version package) (
  lib.filterAttrs (target: _package: lib.elem target enabledTargets) unikernel
)
