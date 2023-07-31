{
  description = "NgiPkgs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # Set the defaultSystem list for flake-utils to only x86_64-linux
  inputs.systems.url = "github:nix-systems/x86_64-linux";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    ...
  }: let
    buildOutputs = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in {
      packages = import ./all-packages.nix {inherit (pkgs) newScope;
      };
      nixosModules = {
        modules = import ./modules/all-modules.nix;
        ngipkgs = {...}: {
          # Inject an additional argument into the module system evaluation.
          # This way our package set can be accessed separately and we don't have
          # to muck around with overlays (which don't work with flakes as you'd expect)
          _module.args.ngipkgs = self.packages.${system};
        };
      };

      formatter = treefmtEval.config.build.wrapper;
    };

    checkOutputs = system: let
      pkgs = nixpkgs.legacyPackages.${system} // self.packages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      ngipkgsModule = self.nixosModules.${system}.ngipkgs;
    in {
      # Configurations have to go in checkOutputs (ie, avoid `eachDefaultSystem`) to generate
      # a single attribute name for nixos-container deployments (`<config-name>`), because
      # nixos-container can't parse dot-separated sequence attribute paths (`x86_64-linux.<config-name>`).
      nixosConfigurations = let
        all-configurations = import ./configs/all-configurations.nix {inherit pkgs;};
        inject-ngipkgs = k: v: pkgs.nixos ({...}: {imports = [ngipkgsModule v];});
      in
        builtins.mapAttrs inject-ngipkgs all-configurations;

      # To generate a Hydra jobset for CI builds of all packages
      # https://hydra.ngi0.nixos.org/jobset/ngipkgs/main
      hydraJobs = {
        packages.${system} = self.packages.${system};
      };

      # For .github/workflows/ci.yaml to *build* all packages, because
      # `nix flake check` only evaluates packages, but it builds checks.
      checks.${system} =
        self.packages.${system}
        // {
          formatting = treefmtEval.config.build.check self;
          test-pretalx =
            pkgs.nixosTest
            (import ./tests/pretalx/pretalx.nix {
              inherit ngipkgsModule pkgs;
            });
        };
    };
  in
    (flake-utils.lib.eachDefaultSystem buildOutputs) // (checkOutputs "x86_64-linux");
}
