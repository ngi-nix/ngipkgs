{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      classic' = import ./. {
        sources = inputs;
        system = null;
      };
      inherit (classic') lib lib';

      inherit (lib)
        concatMapAttrs
        filterAttrs
        ;

      overlay = classic'.overlays.default;

      toplevel = machine: machine.config.system.build.toplevel;

      # Finally, define the system-agnostic outputs.
      systemAgnosticOutputs = {
        nixosConfigurations = {
          makemake = import ./infra/makemake { inherit inputs; };
        };

        nixosModules = {
          default.nixpkgs.overlays = [ overlay ];
        } // lib'.flattenAttrs "." classic'.nixos-modules;

        # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
        overlays.default = overlay;
      };

      eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          classic = import ./. {
            sources = inputs;
            inherit system;
          };

          inherit (classic) pkgs ngipkgs optionsDoc;
        in
        rec {
          packages = ngipkgs // {
            overview = import ./overview {
              inherit
                lib
                lib'
                self
                nixpkgs
                system
                ;
              pkgs = pkgs // ngipkgs;
              projects = classic.projects;
              options = optionsDoc.optionsNix;
            };

            options =
              pkgs.runCommand "options.json"
                {
                  build = optionsDoc.optionsJSON;
                }
                ''
                  mkdir $out
                  cp $build/share/doc/nixos/options.json $out/
                '';
          };

          # buildbot executes `nix flake check`, therefore this output
          # should only contain derivations that can built within CI.
          # See ./infra/makemake/buildbot.nix for how it is set up.
          # NOTE: `nix flake check` requires a flat attribute set of derivations, which is an annoying constraint...
          checks =
            let
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
                        "projects/${projectName}/nixos/check" = pkgs.writeText "${projectName}-eval-check" (
                          lib.strings.toJSON classic.check-projects.${projectName}
                        );
                      };
                    in
                    checksForNixosTests // checksForNixosTypes;
                in
                concatMapAttrs checksForProject classic.projects;

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
                "infra/pre-commit" = pre-commit-hooks.lib.${system}.run {
                  src = ./.;
                  hooks = {
                    actionlint.enable = true;
                    nixfmt-rfc-style.enable = true;
                  };
                };
                "infra/makemake" = toplevel self.nixosConfigurations.makemake;
                "infra/overview" = self.packages.${system}.overview;
              };
            in
            checksForInfrastructure // checksForAllProjects // checksForAllPackages;

          devShells.default = pkgs.mkShell {
            inherit (checks."infra/pre-commit") shellHook;
            buildInputs = checks."infra/pre-commit".enabledPackages ++ classic.shell.nativeBuildInputs;
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
        }
      );
    in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
