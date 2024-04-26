{
  description = "NGIpkgs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # Set default system to `x86_64-linux`,
  # as we currently only support Linux.
  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/x86_64-linux";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    sops-nix,
    rust-overlay,
    pre-commit-hooks,
    dream2nix,
    ...
  }: let
    # Take Nixpkgs' lib and update it with the definitions in ./lib.nix
    lib = nixpkgs.lib.recursiveUpdate nixpkgs.lib (import ./lib.nix {inherit (nixpkgs) lib;});

    inherit
      (builtins)
      mapAttrs
      attrValues
      isPath
      ;

    inherit
      (lib)
      concatMapAttrs
      mapAttrs'
      foldr
      recursiveUpdate
      nameValuePair
      nixosSystem
      filterAttrs
      attrByPath
      mapAttrByPath
      flattenAttrsDot
      flattenAttrsSlash
      ;

    importProjects = {
      pkgs ? {},
      sources ? {
        configurations = rawNixosConfigs;
        modules = extendedModules;
      },
    }:
      import ./projects {inherit lib pkgs sources;};

    # Functions to ease access of imported projects, by "picking" certain paths.
    pick = rec {
      packages = mapAttrByPath ["packages"] {};
      modulePaths = x:
        concatMapAttrs (n: v:
          if isPath v
          then {${n} = v;}
          else {})
        (modules x);
      modules = projects: flattenAttrsDot (lib.foldl recursiveUpdate {} (attrValues (mapAttrByPath ["nixos" "modules"] {} projects)));
      tests = mapAttrByPath ["nixos" "tests"] {};
      configurations = projects: mapAttrs (_: v: mapAttrs (_: v: v.path) v) (mapAttrByPath ["nixos" "configurations"] {} projects);
    };

    importPackages = pkgs: let
      nixosTests = pick.tests (importProjects {pkgs = pkgs // allPackages;});

      callPackage = pkgs.newScope (
        allPackages // {inherit callPackage nixosTests;}
      );

      pkgsByName = import ./pkgs/by-name {
        inherit (pkgs) lib;
        inherit callPackage dream2nix pkgs;
      };

      explicitPkgs = import ./pkgs {
        inherit (pkgs) lib;
        inherit callPackage;
      };

      allPackages = pkgsByName // explicitPkgs;
    in
      allPackages;

    importNixpkgs = system: overlays:
      import nixpkgs {inherit system overlays;};

    rawNixosConfigs = flattenAttrsSlash (pick.configurations (importProjects {}));

    # Attribute set containing all modules obtained via `inputs` and defined
    # in this flake towards definition of `nixosConfigurations` and `nixosTests`.
    extendedModules =
      self.nixosModules
      // {
        sops-nix = sops-nix.nixosModules.default;
      };

    nixosConfigurations =
      mapAttrs
      (_: config: nixosSystem {modules = [config ./dummy.nix] ++ attrValues extendedModules;})
      rawNixosConfigs;

    eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = importNixpkgs system [rust-overlay.overlays.default];

      importedProjects = importProjects {
        pkgs = pkgs // importPack;
      };

      toplevel = name: config: nameValuePair "nixosConfigs/${name}" config.config.system.build.toplevel;

      importPack = importPackages pkgs;

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
    in {
      packages =
        importPack
        // {
          overview = import ./overview {
            inherit lib pkgs self;
            projects = importedProjects;
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

      checks = mapAttrs' toplevel nixosConfigurations;
    });

    x86_64-linuxOutputs = let
      system = flake-utils.lib.system.x86_64-linux;
      pkgs = importNixpkgs system [self.overlays.default];
      # Dream2nix is failing to pass through the meta attribute set.
      # As a workaround, consider packages with empty meta as non-broken.
      nonBrokenPkgs = filterAttrs (_: v: !(attrByPath ["meta" "broken"] false v)) self.packages.${system};
    in {
      # Github Actions executes `nix flake check` therefore this output
      # should only contain derivations that can built within CI.
      # See `.github/workflows/ci.yaml`.
      checks.${system} =
        # For `nix flake check` to *build* all packages, because by default
        # `nix flake check` only evaluates packages and does not build them.
        (mapAttrs' (name: check: nameValuePair "packages/${name}" check) nonBrokenPkgs)
        // {
          inherit (self.packages.${system}) overview;
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
            };
          };
        };

      devShell.${system} = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };

      formatter.${system} = pkgs.writeShellApplication {
        name = "formatter";
        text = ''
          # shellcheck disable=all
          shell-hook () {
            ${self.checks.${system}.pre-commit-check.shellHook}
          }

          shell-hook
          pre-commit run --all-files
        '';
      };

      # To generate a Hydra jobset for CI builds of all packages and tests.
      # See <https://hydra.ngi0.nixos.org/jobset/ngipkgs/main>.
      hydraJobs = let
        passthruTests = concatMapAttrs (name: value:
          if value ? passthru.tests
          then {${name} = value.passthru.tests;}
          else {})
        nonBrokenPkgs;
      in {
        packages.${system} = nonBrokenPkgs;
        tests.${system} = {
          passthru = passthruTests;
          nixos = pick.tests (importProjects {pkgs = pkgs // nonBrokenPkgs;});
        };

        nixosConfigurations.${system} =
          mapAttrs
          (name: config: config.config.system.build.toplevel)
          nixosConfigurations;
      };
    };

    systemAgnosticOutputs = {
      inherit nixosConfigurations;

      nixosModules =
        {
          unbootable = ./modules/unbootable.nix;
          # The default module adds the default overlay on top of Nixpkgs.
          # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
          default.nixpkgs.overlays = [self.overlays.default];
        }
        // (filterAttrs (_: v: v != null) (pick.modules (importProjects {})));

      # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
      overlays.default = final: prev: importPackages prev;
    };
  in
    foldr recursiveUpdate {} [
      eachDefaultSystemOutputs
      x86_64-linuxOutputs
      systemAgnosticOutputs
    ];
}
