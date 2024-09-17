{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
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
      (builtins)
      mapAttrs
      attrValues
      ;

    inherit
      (lib)
      concatMapAttrs
      mapAttrs'
      foldr
      recursiveUpdate
      nameValuePair
      filterAttrs
      attrByPath
      ;

    inherit
      (lib')
      flattenAttrsDot
      flattenAttrsSlash
      mapAttrByPath
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

    rawExamples = flattenAttrsSlash (mapAttrs (_: v: mapAttrs (_: v: v.path) v) (
      mapAttrByPath ["nixos" "examples"] {} rawNgiProjects
    ));

    rawNixosModules = flattenAttrsDot (lib.foldl recursiveUpdate {} (attrValues (
      mapAttrByPath ["nixos" "modules"] {} rawNgiProjects
    )));

    nixosModules =
      {
        unbootable = ./modules/unbootable.nix;
        # The default module adds the default overlay on top of Nixpkgs.
        # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
        default.nixpkgs.overlays = [overlay];
      }
      // (filterAttrs (_: v: v != null) rawNixosModules);

    # Next, extend the modules with modules that are additionally required in the tests and examples.
    extendedNixosModules =
      nixosModules
      // {
        sops-nix = sops-nix.nixosModules.default;
      };

    mkNixosSystem = config: nixosSystem {modules = [config ./dummy.nix] ++ attrValues extendedNixosModules;};

    toplevel = machine: machine.config.system.build.toplevel;

    extendedNixosConfigurations = mapAttrs (_: mkNixosSystem) rawExamples;

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
        extendedNixosConfigurations
        // {makemake = import ./infra/makemake {inherit inputs;};};

      inherit nixosModules;

      # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
      overlays.default = overlay;
    };

    eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          overlay
        ];
      };

      ngiPackages = import ./pkgs/by-name {inherit pkgs lib dream2nix;};

      # Dream2nix is failing to pass through the meta attribute set.
      # As a workaround, consider packages with empty meta as non-broken.
      nonBrokenNgiPackages = filterAttrs (_: v: !(attrByPath ["meta" "broken"] false v)) ngiPackages;

      ngiProjects = importNgiProjects (pkgs // ngiPackages);

      nonBrokenNgiProjects = importNgiProjects (pkgs // nonBrokenNgiPackages);

      optionsDoc = pkgs.nixosOptionsDoc {
        options =
          (import (nixpkgs + "/nixos/lib/eval-config.nix") {
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
      legacyPackages = {
        nixosTests = mapAttrByPath ["nixos" "tests"] {} ngiProjects;
      };

      packages =
        ngiPackages
        // {
          overview = import ./overview {
            inherit lib pkgs self;
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
        checksForNixosTests = projectName: tests:
          concatMapAttrs
          (testName: test: {"projects/${projectName}/nixos/tests/${testName}" = test;})
          tests;

        checksForNixosExamples = projectName: examples:
          concatMapAttrs
          (exampleName: example: {"projects/${projectName}/nixos/examples/${exampleName}" = toplevel (mkNixosSystem example.path);})
          examples;

        checksForProject = projectName: project:
          (checksForNixosTests projectName (project.nixos.tests or {}))
          // (checksForNixosExamples projectName (project.nixos.examples or {}));

        checksForAllProjects =
          concatMapAttrs
          checksForProject
          nonBrokenNgiProjects;

        checksForPackageDerivation = packageName: package: {"packages/${packageName}" = package;};

        checksForPackagePassthruTests = packageName: tests: (concatMapAttrs (passthruName: test: {"packages/${packageName}/passthru/${passthruName}" = test;}) tests);

        checksForPackage = packageName: package:
          (checksForPackageDerivation packageName package)
          // (checksForPackagePassthruTests packageName (package.passthru.tests or {}));

        checksForAllPackages =
          concatMapAttrs
          checksForPackage
          nonBrokenNgiPackages;
      in
        checksForAllProjects
        // checksForAllPackages
        // {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              alejandra.enable = true;
            };
          };
          "infra/makemake" = toplevel self.nixosConfigurations.makemake;
          "infra/overview" = self.packages.${system}.overview;
        };

      devShells.default = pkgs.mkShell {
        inherit (checks.pre-commit) shellHook;
        buildInputs = checks.pre-commit.enabledPackages;
      };

      formatter = pkgs.writeShellApplication {
        name = "formatter";
        text = ''
          # shellcheck disable=all
          shell-hook () {
            ${checks.pre-commit.shellHook}
          }

          shell-hook
          pre-commit run --all-files
        '';
      };
    });
  in
    foldr recursiveUpdate {} [
      eachDefaultSystemOutputs
      systemAgnosticOutputs
    ];
}
