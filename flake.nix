{
  description = "NgiPkgs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # Set default system to `x86_64-linux`,
  # as we currently only support Linux.
  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/x86_64-linux";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    nix-php-composer-builder,
    flake-utils,
    treefmt-nix,
    sops-nix,
    ...
  }:
    with builtins; let
      importPackages = pkgs:
        import ./all-packages.nix {
          inherit (pkgs) newScope;
        };

      importNixpkgs = system: overlays:
        import nixpkgs {
          inherit system overlays;
        };

      importNixosConfigurations = import ./configs/all-configurations.nix;

      loadTreefmt = pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      # Attribute set containing all modules obtained via `inputs` and defined in this flake towards definition of `nixosConfigurations` and `nixosTests`.
      extendedModules =
        self.nixosModules
        // {
          sops-nix = sops-nix.nixosModules.default;
        };

      # Compute outputs that are invariant in the system architecture.
      allSystemsOutputs = system: let
        pkgs = importNixpkgs system [
          nix-php-composer-builder.overlays.default
        ];
        treefmtEval = loadTreefmt pkgs;
      in {
        packages = importPackages pkgs;
        formatter = treefmtEval.config.build.wrapper;
      };
    in
      # We merge three attribute sets to construct all outputs:
      #  1. Outputs that are invariant in the system architecture
      #     via `flake-utils.lib.eachDefaultSystem`.
      #  2. Outputs that are specific to a system architecture
      #     (as of 2023-08-22, only `x86_64-linux`).
      #  3. Outputs that are not tied to any system at all.
      #
      # 1.
      (flake-utils.lib.eachDefaultSystem allSystemsOutputs)
      #
      # 2.
      // (let
        linuxSystem = "x86_64-linux";
        pkgs = importNixpkgs linuxSystem [self.overlays.default];
        treefmtEval = loadTreefmt pkgs;

        # A function that removes packages that are known to
        # have issues from a set of packages.
        # Packages that are known to have issues, and should not
        # be built by `nix flake check` or Hydra.
        # Mark every entry with a GitHub issue that tracks
        # respective issues.
        filterBroken = nixpkgs.lib.filterAttrs (_: x: !x.meta.broken);
      in {
        # Github Actions executes `nix flake check` therefore this output
        # should only contain derivations that can built within CI.
        # See `.github/workflows/ci.yaml`.
        checks.${linuxSystem} =
          # For `nix flake check` to *build* all packages, because by default
          # `nix flake check` only evaluates packages and does not build them.
          (filterBroken self.packages.${linuxSystem})
          // {
            formatting = treefmtEval.config.build.check self;
          };

        # To generate a Hydra jobset for CI builds of all packages.
        # See <https://hydra.ngi0.nixos.org/jobset/ngipkgs/main>.
        hydraJobs.packages.${linuxSystem} = (filterBroken self.packages.${linuxSystem});

        # `nixosTests` is a non-standard name for a flake output.
        # See <https://github.com/ngi-nix/ngipkgs/issues/28>.
        nixosTests.${linuxSystem} = mapAttrs (_: pkgs.nixosTest) (import ./tests/all-tests.nix {
          modules = extendedModules;
          configurations = importNixosConfigurations;
        });
      })
      #
      # 3.
      // {
        nixosConfigurations =
          mapAttrs (
            _: config:
              nixpkgs.lib.nixosSystem {
                modules = [config] ++ nixpkgs.lib.attrValues extendedModules;
              }
          )
          importNixosConfigurations;

        nixosModules =
          (import ./modules/all-modules.nix)
          // {
            # The default module adds the default overlay on top of nixpkgs.
            # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
            default.nixpkgs.overlays = [self.overlays.default];
          };

        # Overlays a package set (e.g. nixpkgs) with the packages defined in this flake.
        overlays.default = final: prev: importPackages prev;
      };
}
