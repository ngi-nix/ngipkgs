{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.hydra.url = "github:NixOS/hydra/nix-next";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:Mic92/buildbot-nix";

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  outputs = {
    hydra,
    self,
    nixpkgs,
    flake-utils,
    sops-nix,
    pre-commit-hooks,
    dream2nix,
    buildbot-nix,
    ...
  }: let
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
      optionalAttrs
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

    # NGI packages are imported from ./pkgs/by-name/default.nix.
    importNgiPackages = pkgs:
      import ./pkgs/by-name {
        inherit (pkgs) lib;
        inherit dream2nix pkgs;
      };

    # NGI projects are imported from ./projects/default.nix.
    # Each project includes packages, and optionally, modules, configurations and tests.
    importNgiProjects = {
      pkgs ? {},
      sources ? {
        configurations = rawNixosConfigurations;
        modules = extendedNixosModules;
      },
    }:
      import ./projects {inherit lib pkgs sources;};

    # The above definition reimports `rawNixosConfigurations` and `extendedNixosModules` into `sources`.
    # As configurations and modules are system-agnostic, they are defined by passing `{}` to `importNgiProjects`.
    rawNgiProjects = importNgiProjects {};

    rawNixosConfigurations = flattenAttrsSlash (mapAttrs (_: v: mapAttrs (_: v: v.path) v) (
      mapAttrByPath ["nixos" "configurations"] {} rawNgiProjects
    ));

    rawNixosModules = flattenAttrsDot (lib.foldl recursiveUpdate {} (attrValues (
      mapAttrByPath ["nixos" "modules"] {} rawNgiProjects
    )));

    extendedNixosModules =
      self.nixosModules
      // {
        sops-nix = sops-nix.nixosModules.default;
      };

    extendedNixosConfigurations =
      mapAttrs
      (_: config: nixosSystem {modules = [config ./dummy.nix] ++ attrValues extendedNixosModules;})
      rawNixosConfigurations;

    # Then, define the system-specific outputs.
    eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      ngiPackages = importNgiPackages pkgs;

      ngiProjects = importNgiProjects {
        pkgs = pkgs // ngiPackages;
      };

      toplevel = name: config: nameValuePair "nixosConfigs/${name}" config.config.system.build.toplevel;

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
              ++ attrValues self.nixosModules;
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
            pkgs.runCommand "options.json" {
              build = optionsDoc.optionsJSON;
            } ''
              mkdir $out
              cp $build/share/doc/nixos/options.json $out/
            '';
        };

      checks =
        mapAttrs' toplevel extendedNixosConfigurations
        // {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              actionlint.enable = true;
              alejandra.enable = true;
            };
          };
          makemake = self.nixosConfigurations.makemake.config.system.build.toplevel;
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

    x86_64-linuxOutputs = let
      system = flake-utils.lib.system.x86_64-linux;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };

      # Include all packages (with overview and options)
      ngiPackages = self.packages.${system};

      # Dream2nix is failing to pass through the meta attribute set.
      # As a workaround, consider packages with empty meta as non-broken.
      nonBrokenNgiPackages = filterAttrs (_: v: !(attrByPath ["meta" "broken"] false v)) ngiPackages;

      nonBrokenNgiProjects = importNgiProjects {
        pkgs = pkgs // nonBrokenNgiPackages;
      };
    in {
      # buildbot executes `nix flake check`, therefore this output
      # should only contain derivations that can built within CI.
      # see ./infra/makemake/buildbot.nix
      checks.${system} =
        # For `nix flake check` to *build* all packages, because by default
        # `nix flake check` only evaluates packages and does not build them.
        mapAttrs' (name: check: nameValuePair "packages/${name}" check) nonBrokenNgiPackages;

      # To generate a Hydra jobset for CI builds of all packages and tests.
      # See <https://hydra.ngi0.nixos.org/jobset/ngipkgs/main>.
      hydraJobs = let
        passthruTests = concatMapAttrs (name: value:
          optionalAttrs (value ? passthru.tests) {${name} = value.passthru.tests;})
        nonBrokenNgiPackages;
      in {
        packages.${system} = nonBrokenNgiPackages;
        tests.${system} = {
          passthru = passthruTests;
          nixos = mapAttrByPath ["nixos" "tests"] {} nonBrokenNgiProjects;
        };

        nixosConfigurations.${system} =
          mapAttrs
          (name: config: config.config.system.build.toplevel)
          extendedNixosConfigurations;
      };
    };

    systemAgnosticOutputs = {
      nixosConfigurations =
        extendedNixosConfigurations
        // {
          makemake = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              # Use NixOS module for pinned Hydra, but note that this doesn't
              # set the package to be from that repo.  It juse uses the stock
              # `pkgs.hydra_unstable` by default.
              hydra.nixosModules.hydra

              # Setup both a master and a worker buildbot instance in this host
              buildbot-nix.nixosModules.buildbot-master
              buildbot-nix.nixosModules.buildbot-worker

              {
                # Here, set the Hydra package to use the (complete
                # self-contained, pinning nix, nixpkgs, etc.) default Hydra
                # build. Other than this one package, those pins versions are
                # not used.
                services.hydra.package = hydra.packages.x86_64-linux.default;
              }

              sops-nix.nixosModules.default

              ./infra/makemake/configuration.nix

              {
                #nix.registry.nixpkgs.flake = nixpkgs;
                nix.nixPath = ["nixpkgs=${nixpkgs}"];
              }
            ];
          };
        };

      nixosModules =
        {
          unbootable = ./modules/unbootable.nix;
          # The default module adds the default overlay on top of Nixpkgs.
          # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
          default.nixpkgs.overlays = [self.overlays.default];
        }
        // (filterAttrs (_: v: v != null) rawNixosModules);

      # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
      overlays.default = final: prev: importNgiPackages prev;
    };
  in
    foldr recursiveUpdate {} [
      eachDefaultSystemOutputs
      x86_64-linuxOutputs
      systemAgnosticOutputs
    ];
}
