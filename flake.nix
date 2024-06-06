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
    # Take Nixpkgs' lib and pass it to get the definitions in ./lib.nix
    lib = import (nixpkgs + "/lib");
    lib' = import ./lib.nix {inherit lib;};
    helpers = import ./nix/helpers.nix {inherit nixpkgs dream2nix sops-nix;};

    inherit
      (builtins)
      mapAttrs
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
      mapAttrByPath
      ;

    inherit
      (helpers)
      importNgiProjects
      rawOutputs
      extendedNixosConfigurations
      ;

    eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (system: let
      ngiLegacyPackages = import ./. {inherit system nixpkgs dream2nix sops-nix self;};

      pkgs = import nixpkgs {inherit system;};

      toplevel = name: config: nameValuePair "nixosConfigs/${name}" config.config.system.build.toplevel;
    in rec {
      legacyPackages = {
        inherit (ngiLegacyPackages) nixosTests;
      };

      packages = filterAttrs (n: _: n != "nixosTests") ngiLegacyPackages;

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

      nonBrokenNgiProjects = importNgiProjects (pkgs // nonBrokenNgiPackages);
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

      inherit (rawOutputs) nixosModules overlays;
    };
  in
    foldr recursiveUpdate {} [
      eachDefaultSystemOutputs
      x86_64-linuxOutputs
      systemAgnosticOutputs
    ];
}
