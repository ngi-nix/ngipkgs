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
  perSystem = rec {
    packages = nonBrokenPackages // {
      inherit (default) overview;

      # All manual outputs
      manuals = default.manuals;

      # Combined overview and html manual
      overview-with-manual = pkgs.runCommand "overview-with-manual" { } ''
        mkdir -p $out
        cp -r ${default.overview}/* $out/
        mkdir -p $out/manual
        cp -r ${default.manuals.html}/* $out/manual/
      '';

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
    };

    checks = default.import ./checks.nix { inherit nonBrokenPackages; };

    devShells.default = pkgs.mkShell {
      inherit (checks."infra/pre-commit") shellHook;
      buildInputs = checks."infra/pre-commit".enabledPackages ++ default.shell.nativeBuildInputs;
    };

    formatter = default.formatter.package;
  };
}
