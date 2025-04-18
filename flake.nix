{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.git-hooks.url = "github:fricklerhandwerk/git-hooks";
  inputs.git-hooks.flake = false;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";
  inputs.yants.url = "git+https://code.tvl.fyi/depot.git:/nix/yants.git";
  inputs.yants.flake = false;

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      classic' = (import ./. { }).ngipkgs;
      inherit (classic') lib lib';

      inherit (lib)
        attrValues
        concatMapAttrs
        filterAttrs
        mapAttrs
        ;

      nixosSystem =
        args:
        import (nixpkgs + "/nixos/lib/eval-config.nix") (
          {
            inherit lib;
            system = null;
          }
          // args
        );

      mkNixosSystem =
        config:
        nixosSystem {
          modules =
            [
              config
              {
                nixpkgs.hostPlatform = "x86_64-linux";
                system.stateVersion = "23.05";

                # The examples that the flake exports are not meant to be used/booted directly.
                # See <https://github.com/ngi-nix/ngipkgs/issues/128> for more information.
                boot = {
                  initrd.enable = false;
                  kernel.enable = false;
                  loader.grub.enable = false;
                };
              }
            ]
            # TODO: this needs to take a different shape,
            # otherwise the transformation to obtain it is confusing
            ++ classic'.extendedNixosModules;
        };

      toplevel = machine: machine.config.system.build.toplevel;

      # Finally, define the system-agnostic outputs.
      systemAgnosticOutputs = {
        nixosConfigurations =
          # TODO: remove these, noone will (or can even, realistically) use them
          mapAttrs (_: mkNixosSystem) classic'.examples // {
            makemake = import ./infra/makemake { inherit inputs; };
          };

        inherit (classic') nixosModules;
      };

      eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          classic = (import ./. { }).nixpkgs { inherit system; };

          inherit (classic) pkgs ngipkgs;

          ngiProjects = classic.projects;

          overlay = classic.overlays.default;

          rawNixosModules = (import ./lib.nix { inherit lib; }).flattenAttrs "." (
            lib.foldl lib.recursiveUpdate { } (
              lib.attrValues (lib.mapAttrs (_: project: project.nixos.modules) ngiProjects)
            )
          );

          nixosModules = {
            # The default module adds the default overlay on top of Nixpkgs.
            # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
            default.nixpkgs.overlays = [ overlay ];
          } // rawNixosModules;

          optionsDoc = pkgs.nixosOptionsDoc {
            options =
              (nixosSystem {
                inherit system;
                modules = [
                  {
                    networking = {
                      domain = "invalid";
                      hostName = "options";
                    };

                    system.stateVersion = "23.05";
                  }
                ] ++ attrValues nixosModules;
              }).options;
          };
        in
        rec {
          # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
          overlays.default = overlay;

          packages = ngipkgs // {
            overview = import ./overview {
              inherit lib lib' self;
              pkgs = pkgs // ngipkgs;
              projects = ngiProjects;
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

                      checksForNixosExamples = concatMapAttrs (exampleName: example: {
                        "projects/${projectName}/nixos/examples/${exampleName}" = toplevel (mkNixosSystem example.module);
                      }) project.nixos.examples;
                    in
                    checksForNixosTests // checksForNixosExamples;
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
                "infra/pre-commit" = classic.pre-commit-hook;
                "infra/makemake" = toplevel self.nixosConfigurations.makemake;
                "infra/overview" = self.packages.${system}.overview;
                "infra/templates" = classic.templates.project;
              };
            in
            checksForInfrastructure // checksForAllProjects // checksForAllPackages;

          devShells.default = pkgs.mkShell {
            inherit (checks."infra/pre-commit") shellHook;
            buildInputs = checks."infra/pre-commit".nativeBuildInputs;
          };

          inherit (classic) formatter;
        }
      );
    in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
