{
  lib,
  flake,

  checks,
  formatter,
  projects,
  nonBrokenPackages,
  overview-with-manuals,
  ...
}:
# buildbot executes `nix flake check`, therefore this output
# should only contain derivations that can built within CI.
# See ./infra/makemake/buildbot.nix for how it is set up.

# NOTE: `nix flake check` requires a flat attribute set of derivations, which
# is an annoying constraint...

let
  inherit (lib)
    concatMapAttrs
    ;

  # TODO: rename toplevel attributes?
  self = flake;

  toplevel = machine: machine.config.system.build.toplevel; # for makemake

  checksForAllProjects = concatMapAttrs (
    projectName: project: lib.flattenAttrs "/" projects.${projectName}
  ) projects;

  checksForAllPackages =
    let
      checksForPackage =
        packageName: package:
        let
          checksForPackageDerivation = {
            "packages/${packageName}" = package;
          };
          checksForPackagePassthruTests = concatMapAttrs (passthruName: test: {
            "packages/${packageName}-${passthruName}" = test;
          }) (package.passthru.tests or { });
        in
        checksForPackageDerivation // checksForPackagePassthruTests;
    in
    concatMapAttrs checksForPackage nonBrokenPackages;

  checksForInfrastructure = {
    "infra/pre-commit" = formatter.hooks.pre-commit;
    "infra/makemake" = toplevel self.nixosConfigurations.makemake;
    "infra/overview" = overview-with-manuals;
  };
in
checksForInfrastructure // checksForAllProjects // checksForAllPackages
