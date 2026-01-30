{
  lib,
  pkgs,
  default,
  ...
}:
let
  flattenFlakeAttrs =
    attrs:
    lib.pipe attrs [
      (lib.flattenAttrs "/")
      # everything must evaluate
      (lib.filterAttrs (_: v: lib.isDerivation v && !v.meta.broken or false))
    ];

  flattenedProjects = flattenFlakeAttrs default.projects;
  nonBrokenPackages = flattenFlakeAttrs default.ngipkgs;
in
{
  # system-independant (e.g. nixosModules)
  systemAgnostic = {
    lib = default.devLib;

    nixosConfigurations = {
      makemake = import ../../infra/makemake { inputs = default.sources; };
    };

    # WARN: this is currently unstable and subject to change in the future
    nixosModules = default.nixos-modules;

    # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
    overlays.default = default.overlays.default;

    projects = flattenedProjects;
  };

  # depends on the system (e.g. packages.x86_64-linux)
  perSystem = {
    packages = {
      inherit (default)
        overview
        overview-with-manual
        ;

      # Configuration options in JSON
      options =
        pkgs.runCommand "options.json"
          {
            build = default.optionsDoc.optionsJSON;
          }
          ''
            mkdir $out
            cp $build/share/doc/nixos/options.json $out/
          '';
    }
    // nonBrokenPackages
    // flattenFlakeAttrs { inherit (default) manuals; };

    checks = default.import ./checks.nix { inherit nonBrokenPackages; };

    devShells.default = default.shell.finalPackage;

    formatter = default.formatter.package;
  };
}
