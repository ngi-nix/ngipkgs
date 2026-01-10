{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sbt-derivation.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sbt-derivation.inputs.flake-utils.follows = "flake-utils";
  inputs.sbt-derivation.url = "github:zaninime/sbt-derivation";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.treefmt-nix.follows = "treefmt-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";
  inputs.nixdoc-to-github.flake = false;
  inputs.nixdoc-to-github.url = "github:fricklerhandwerk/nixdoc-to-github";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";
  inputs.devshell.url = "github:numtide/devshell";

  inputs.nix-filter.url = "github:numtide/nix-filter/3e1fff9";

  # FixMe(maint/upstream): merge this branch upstream
  #inputs.opam-nix.url = "github:tweag/opam-nix";
  inputs.opam-nix.url = "github:ju1m/opam-nix/materialize-monorepo";
  inputs.opam-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.opam-nix.inputs.flake-utils.follows = "flake-utils";
  inputs.opam-nix.inputs.opam2json.follows = "opam2json";
  inputs.opam-nix.inputs.opam-repository.follows = "opam-repository";
  inputs.opam-nix.inputs.opam-overlays.follows = "opam-overlays";
  inputs.opam-nix.inputs.mirage-opam-overlays.follows = "mirage-opam-overlays";

  inputs.opam2json.url = "github:tweag/opam2json";
  inputs.opam2json.inputs.nixpkgs.follows = "nixpkgs";

  # update ocaml-related overlays to use new-enough ocaml packages
  inputs.opam-repository = {
    url = "github:ocaml/opam-repository";
    flake = false;
  };
  inputs.opam-overlays = {
    url = "github:dune-universe/opam-overlays";
    flake = false;
  };
  inputs.mirage-opam-overlays = {
    url = "github:dune-universe/mirage-opam-overlays";
    flake = false;
  };

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  # Flake attributes are defined in ./maintainers/flake and imported from ./default.nix
  outputs =
    {
      self,
      flake-utils,
      ...
    }@inputs:
    let
      flake = self;
      sources = inputs;

      importFlake =
        arg: (system: (import ./. { inherit flake sources system; }).flakeAttrs.${arg} or { });

      # system-independant (e.g. nixosModules)
      systemAgnosticOutputs = flake-utils.lib.eachDefaultSystemPassThrough (importFlake "systemAgnostic");

      # depends on the system (e.g. packages.x86_64-linux)
      eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (importFlake "perSystem");
    in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
