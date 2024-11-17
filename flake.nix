{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    sops-nix,
    pre-commit-hooks,
    dream2nix,
    buildbot-nix,
    ...
  } @ inputs: let
    # Take Nixpkgs' lib and update it with the definitions in ./lib.nix
    lib = import (nixpkgs + "/lib");
    lib' = import ./lib.nix {inherit lib;};

    inherit
      (lib)
      attrValues
      concatMapAttrs
      filterAttrs
      mapAttrs
      recursiveUpdate
      ;

    # Imported from Nixpkgs
    nixosSystem = args:
      import (nixpkgs + "/nixos/lib/eval-config.nix") ({
          inherit lib;
          system = null;
        }
        // args);

    overlay = final: prev:
      import ./pkgs/by-name {
        pkgs = prev;
        inherit lib dream2nix;
      };

    # NGI projects are imported from ./projects/default.nix.
    # Each project includes packages, and optionally, modules, examples and tests.

    # Note that modules and examples are system-agnostic, so import them first.
    rawNgiProjects = import ./projects {
      inherit lib;
      sources = {inherit inputs;};
    };

    rawExamples = lib'.flattenAttrs "/" (
      mapAttrs
      (_: project: mapAttrs (_: example: example.path) project.nixos.examples)
      rawNgiProjects
    );

    rawNixosModules = lib'.flattenAttrs "." (lib.foldl recursiveUpdate {} (attrValues (
      mapAttrs (_: project: project.nixos.modules) rawNgiProjects
    )));

    nixosModules =
      {
        # The default module adds the default overlay on top of Nixpkgs.
        # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
        default.nixpkgs.overlays = [overlay];
      }
      // rawNixosModules;

    # Next, extend the modules with modules that are additionally required in the tests and examples.
    extendedNixosModules =
      nixosModules
      // {
        sops-nix = sops-nix.nixosModules.default;
      };

    mkNixosSystem = config:
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
          ++ attrValues extendedNixosModules;
      };

    toplevel = machine: machine.config.system.build.toplevel;

    # Then, import packages and tests, which are system-dependent.
    importNgiProjects = pkgs:
      import ./projects {
        inherit lib pkgs;
        sources = {
          inherit inputs;
          examples = rawExamples;
          modules = extendedNixosModules;
          inherit nixpkgs;
        };
      };

    # Finally, define the system-agnostic outputs.
    systemAgnosticOutputs = {
      nixosConfigurations =
        mapAttrs (_: mkNixosSystem) rawExamples
        // {makemake = import ./infra/makemake {inherit inputs;};};

      inherit nixosModules;

      # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
      overlays.default = overlay;
    };

    eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay];
      };

      ngipkgs = import ./pkgs/by-name {inherit pkgs lib dream2nix;};

      ngiProjects = importNgiProjects (pkgs // ngipkgs);

      optionsDoc = pkgs.nixosOptionsDoc {
        options =
          (nixosSystem {
            inherit system;
            modules =
              [
                {
                  networking = {
                    domain = "invalid";
                    hostName = "options";
                  };

                  system.stateVersion = "23.05";
                }
              ]
              ++ attrValues nixosModules;
          })
          .options;
      };
    in rec {
      packages =
        ngipkgs
        // {
          overview = import ./overview {
            inherit lib lib' pkgs self;
            projects = ngiProjects;
            options = optionsDoc.optionsNix;
          };

          options =
            pkgs.runCommand "options.json"
            {
              build = optionsDoc.optionsJSON;
            } ''
              mkdir $out
              cp $build/share/doc/nixos/options.json $out/
            '';
        };

      # buildbot executes `nix flake check`, therefore this output
      # should only contain derivations that can built within CI.
      # See ./infra/makemake/buildbot.nix for how it is set up.
      # NOTE: `nix flake check` requires a flat attribute set of derivations, which is an annoying constraint...
      checks = let
        # everything must evaluate for checks to run
        nonBrokenPackages = filterAttrs (_: v: ! v.meta.broken or false) ngipkgs;

        checksForAllProjects = let
          checksForProject = projectName: project: let
            checksForNixosTests =
              concatMapAttrs
              (testName: test: {"projects/${projectName}/nixos/tests/${testName}" = test;})
              project.nixos.tests;

            checksForNixosExamples =
              concatMapAttrs
              (exampleName: example: {"projects/${projectName}/nixos/examples/${exampleName}" = toplevel (mkNixosSystem example.path);})
              project.nixos.examples;
          in
            checksForNixosTests // checksForNixosExamples;
        in
          concatMapAttrs checksForProject (importNgiProjects (pkgs // nonBrokenPackages));

        checksForAllPackages = let
          checksForPackage = packageName: package: let
            checksForPackageDerivation = {"packages/${packageName}" = package;};
            checksForPackagePassthruTests =
              concatMapAttrs
              (passthruName: test: {"packages/${packageName}/passthru/${passthruName}" = test;})
              (package.passthru.tests or {});
          in
            checksForPackageDerivation // checksForPackagePassthruTests;
        in
          concatMapAttrs checksForPackage nonBrokenPackages;

        checksForInfrastructure = {
          "infra/pre-commit" = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              alejandra.enable = true;
            };
          };
          "infra/makemake" = toplevel self.nixosConfigurations.makemake;
          "infra/overview" = self.packages.${system}.overview;
        };
      in
        checksForInfrastructure
        // checksForAllProjects
        // checksForAllPackages;

      devShells.default = pkgs.mkShell {
        inherit (checks."infra/pre-commit") shellHook;
        buildInputs = checks."infra/pre-commit".enabledPackages;
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
    });
  in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
