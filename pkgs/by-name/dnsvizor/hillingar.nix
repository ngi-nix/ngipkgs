{
  lib,
  hillingar,
  fetchFromGitHub,
  gmp,
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
        # in .cirrus.yml, there are ocaml versions used by upstream CI
        unikernelName = "dnsvizor";
        depexts = [ gmp ];
        monorepoQuery = {
        };
        query = {
        };
      };

  enabledTargets = [ "unix" ]; # TODO(linj) build more targtes such as hvt

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
