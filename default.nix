{
  sources ? (import ./flake-compat.nix {root = ./.;}).inputs,
  system ? builtins.currentSystem,
  pkgs ?
    import sources.nixpkgs {
      config = {};
      overlays = [];
      inherit system;
    },
  lib ? import "${sources.nixpkgs}/lib",
}: let
  dream2nix = (import sources.dream2nix).overrideInputs {inherit (sources) nixpkgs;};
  sops-nix = import "${sources.sops-nix}/modules/sops";
in rec {
  inherit lib pkgs system sources;

  # TODO: we should be exporting our custom functions as `lib`, but refactoring
  # this to use `pkgs.lib` everywhere is a lot of movement
  lib' = import ./lib.nix {inherit lib;};

  overlays.default = final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix;
    };

  examples = with lib; mapAttrs (_: project: mapAttrs (_: example: example.path) project.nixos.examples) projects;

  nixos-modules = with lib;
    foldl recursiveUpdate {} (attrValues (mapAttrs (_: project: project.nixos.modules) projects))
    // {
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      ngipkgs = {...}: {
        nixpkgs.overlays = [overlays.default];
      };
    };

  ngipkgs = import ./pkgs/by-name {inherit pkgs lib dream2nix;};

  projects = import ./projects {
    inherit lib;
    pkgs = pkgs // ngipkgs;
    sources = {
      inputs = sources;
      modules = nixos-modules // {inherit sops-nix;};
      inherit examples;
    };
  };

  shell = pkgs.mkShellNoCC {
    packages = [];
  };
}
