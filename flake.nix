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

  # See <https://github.com/ngi-nix/ngipkgs/issues/24> for plans to support Darwin.
  inputs.systems.url = "github:nix-systems/default-linux";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      classic' = import ./. {
        flake = self;
        system = null;
      };
      inherit (classic') lib extension;

      inherit (lib)
        concatMapAttrs
        filterAttrs
        ;

      overlay = classic'.overlays.default;

      toplevel = machine: machine.config.system.build.toplevel;

      # Finally, define the system-agnostic outputs.
      systemAgnosticOutputs = {
        lib = extension;

        nixosConfigurations = {
          makemake = import ./infra/makemake { inherit inputs; };
        };

        # WARN: this is currently unstable and subject to change in the future
        nixosModules = classic'.nixos-modules;

        # Overlays a package set (e.g. Nixpkgs) with the packages defined in this flake.
        overlays.default = overlay;
      };

      eachDefaultSystemOutputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          classic = import ./. {
            flake = self;
            inherit system;
          };

          inherit (classic) pkgs ngipkgs optionsDoc;
        in
        rec {
          packages = ngipkgs // {
            inherit (classic) overview demos;

            options =
              pkgs.runCommand "options.json"
                {
                  build = optionsDoc.optionsJSON;
                }
                ''
                  mkdir $out
                  cp $build/share/doc/nixos/options.json $out/
                '';
          };

    in
    eachDefaultSystemOutputs // systemAgnosticOutputs;
}
