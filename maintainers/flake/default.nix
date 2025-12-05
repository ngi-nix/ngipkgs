{
  lib,
  pkgs,
  default,
  ...
}:
{
  # system-independant (e.g. nixosModules)
  systemAgnostic = {
    lib = default.overlays.customLib null null;

    nixosConfigurations = {
      makemake = import ../../infra/makemake { inputs = default.sources; };
    };

    toplevel = machine: machine.config.system.build.toplevel; # for makemake

    # WARN: this is currently unstable and subject to change in the future
    nixosModules = default.nixos-modules;

    # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
    overlays.default = default.overlays.default;
  };

  # depends on the system (e.g. packages.x86_64-linux)
  perSystem = rec {
    packages = default.ngipkgs // {
      inherit (default) overview demos;

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

    checks = default.import ./checks.nix { };

    devShells.default = pkgs.mkShell {
      inherit (checks."infra/pre-commit") shellHook;
      buildInputs = checks."infra/pre-commit".enabledPackages ++ default.shell.nativeBuildInputs;
    };

    formatter = pkgs.writeShellApplication {
      name = "formatter";
      text = ''
        # shellcheck disable=all
        shell-hook () {
          ${checks."infra/pre-commit".shellHook}
        }

        shell-hook
        pre-commit run --all-files
      '';
    };
  };
}
