{
  lib,
  flake,
  system,
  sources,

  checks,
  hydrated-projects,
  ngipkgs,
  overview,
  ...
}:
# buildbot executes `nix flake check`, therefore this output
# should only contain derivations that can built within CI.
# See ./infra/makemake/buildbot.nix for how it is set up.
# NOTE: `nix flake check` requires a flat attribute set of derivations, which is an annoying constraint...
let
  inherit (lib)
    filterAttrs
    concatMapAttrs
    ;

  # TODO:
  self = flake;
  projects = hydrated-projects;

  # everything must evaluate for checks to run
  nonBrokenPackages = filterAttrs (_: v: !v.meta.broken or false) ngipkgs;

  checksForAllProjects =
    let
      checksForProject =
        projectName: project:
        let
          checksForNixosTests = concatMapAttrs (testName: test: {
            "projects/${projectName}/nixos/tests/${testName}" = test;
          }) project.nixos.tests;

          checksForNixosTypes = {
            "projects/${projectName}/nixos/check" = checks.${projectName};
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
    "infra/pre-commit" = sources.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        actionlint.enable = true;
        editorconfig-checker.enable = true;
        nixfmt-rfc-style.enable = true;
      };
    };
    "infra/makemake" = with self; toplevel nixosConfigurations.makemake;
    "infra/overview" = overview;
  };
in
checksForInfrastructure // checksForAllProjects // checksForAllPackages
