{
  description = "NGIpkgs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    sops-nix,
    rust-overlay,
    ...
  } @ inputs:
    with builtins; let
      inherit
        (nixpkgs.lib)
        concatMapAttrs
        nixosSystem
        ;

      importPackages = pkgs: let
        # nixosTests is overriden with tests defined in this
        # flake.
        nixosTests =
          pkgs.nixosTests
          // (
            let
              dir = ./tests;
            in
              mapAttrs (name: _:
                pkgs.nixosTest (import (dir + "/${name}") {
                  inherit pkgs;
                  inherit (pkgs) lib;
                  modules = extendedModules;
                  configurations = importNixosConfigurations;
                })) (readDir dir)
          );
        callPackage = pkgs.newScope (
          allPackages // {inherit callPackage nixosTests;}
        );
        pkgsByName = import ./pkgs/by-name {
          inherit (pkgs) lib;
          inherit callPackage;
        };
        explicitPkgs = import ./pkgs {
          inherit (pkgs) lib;
          inherit callPackage inputs;
        };
        allPackages = pkgsByName // explicitPkgs;
      in
        allPackages;

      importNixpkgs = system: overlays:
        import nixpkgs {
          inherit system;
          overlays = overlays ++ [rust-overlay.overlays.default];
        };

      importNixosConfigurations = import ./configs/all-configurations.nix;

      loadTreefmt = pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      # Attribute set containing all modules obtained via `inputs` and defined
      # in this flake towards definition of `nixosConfigurations` and `nixosTests`.
      extendedModules =
        self.nixosModules
        // {
          sops-nix = sops-nix.nixosModules.default;
        };

      nixosSystemWithModules = config: nixosSystem {modules = [config] ++ attrValues extendedModules;};

      # Compute outputs that are invariant in the system architecture.
      allSystemsOutputs = system: let
        pkgs = importNixpkgs system [];
        treefmtEval = loadTreefmt pkgs;
        toplevel = name: config: {
          "${name}-toplevel" = (nixosSystemWithModules config).config.system.build.toplevel;
        };
      in {
        packages = (importPackages pkgs) // (concatMapAttrs toplevel importNixosConfigurations);
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
        nonBrokenPkgs =
          nixpkgs.lib.attrsets.filterAttrs (_: v: !v.meta.broken)
          self.packages.${linuxSystem};
      in {
        # Github Actions executes `nix flake check` therefore this output
        # should only contain derivations that can built within CI.
        # See `.github/workflows/ci.yaml`.
        checks.${linuxSystem} =
          # For `nix flake check` to *build* all packages, because by default
          # `nix flake check` only evaluates packages and does not build them.
          nonBrokenPkgs
          // {
            formatting = treefmtEval.config.build.check self;
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
          packages.${linuxSystem} = nonBrokenPkgs;
          tests.${linuxSystem} = passthruTests;
        };
      })
      #
      # 3.
      // {
        nixosConfigurations =
          mapAttrs (_: config: nixosSystemWithModules config)
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
