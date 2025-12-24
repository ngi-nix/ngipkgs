{
  description = "NGIpkgs";

  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.sbt-derivation.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sbt-derivation.url = "github:zaninime/sbt-derivation";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.buildbot-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.buildbot-nix.url = "github:nix-community/buildbot-nix";
  inputs.nixdoc-to-github.flake = false;
  inputs.nixdoc-to-github.url = "github:fricklerhandwerk/nixdoc-to-github";

  inputs.hillingar.inputs.nixpkgs.follows = "nixpkgs";
  inputs.hillingar.inputs.flake-utils.follows = "flake-utils";
  inputs.hillingar.inputs.opam-repository.follows = "opam-repository";
  inputs.hillingar.inputs.opam-overlays.follows = "opam-overlays";
  inputs.hillingar.inputs.mirage-opam-overlays.follows = "mirage-opam-overlays";
  inputs.hillingar.url = "github:RyanGibb/hillingar";
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
