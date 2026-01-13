{
  lib,
  flake,

  checks,
  formatter,
  hydrated-projects,
  nonBrokenPackages,
  overview,
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
  projects = hydrated-projects;

  toplevel = machine: machine.config.system.build.toplevel; # for makemake

  checksForAllProjects =
    let
      checksForProject =
        projectName: project:
        let
          checksForNixosTests = concatMapAttrs (testName: test: {
            "projects/${projectName}/nixos/tests/${testName}" = test;
          }) project.nixos.tests;

          checksForNixosTypes = {
            "projects/${projectName}/nixos/module-check" = checks.${projectName};
          };
        in
        checksForNixosTests // checksForNixosTypes;
    in
    concatMapAttrs checksForProject projects;

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
    "infra/overview" = overview;
  };
in
checksForInfrastructure // checksForAllProjects // checksForAllPackages
