{
  flake-inputs ? import (fetchTarball {
    url = "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0";
    sha256 = "1j57avx2mqjnhrsgq3xl7ih8v7bdhz1kj3min6364f486ys048bm";
  }),
  flake ? flake-inputs.import-flake { src = ./.; },
  sources ? flake.inputs,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    config = { };
    overlays = import ./pkgs/overlays.nix { lib = nixpkgsLib; };
    inherit system;
  },
  nixpkgsLib ? import "${sources.nixpkgs}/lib",
}:
let
  lib = default.lib;

  flakeAttrs = default.import ./maintainers/flake { };

  default = nixpkgsLib.makeScope pkgs.newScope (self: {
    lib = nixpkgsLib.extend self.overlays.customLib;

    # Similar to `pkgs.callPackage`, but aware of `default` scope attributes.
    # The result is overridable.
    call = self.newScope {
      nixdoc-to-github = pkgs.callPackage sources.nixdoc-to-github { };
      dream2nix = (import sources.dream2nix).overrideInputs { inherit (sources) nixpkgs; };
    };

    # Similar to `import`, but aware of `default` scope attributes.
    # The result is non-overridable.
    import =
      file: args:
      let
        result = self.call file args;
      in
      if lib.isAttrs result then
        removeAttrs result [
          "override"
          "overrideDerivation"
        ]
      else
        result;

    inherit
      pkgs
      system
      sources
      flake
      default # expose final scope
      flakeAttrs
      ;

    ngipkgs = self.import ./pkgs/by-name { };

    shell = self.import ./maintainers/shells/default.nix { };

    overlays = {
      default =
        final: prev:
        self.import ./pkgs/by-name {
          pkgs = prev;
        };

      customLib =
        _: _:
        import ./pkgs/lib.nix {
          lib = nixpkgsLib;
          inherit sources system;
        };

      fixups = self.call ./pkgs/overlays.nix { };
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (self.project-utils.eval-projects) options;
    };

    overview = self.import ./overview {
      self = flake;
      pkgs = pkgs.extend self.overlays.default;
      options = self.optionsDoc.optionsNix;
    };

    nixos-modules =
      # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
      {
        # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
        ngipkgs =
          { ... }:
          {
            nixpkgs.overlays = [ self.overlays.default ] ++ self.overlays.fixups;
          };
      }
      // lib.foldl lib.recursiveUpdate { } (
        map (project: project.nixos.modules) (lib.attrValues self.hydrated-projects)
      );

    project-utils = self.import ./projects {
      pkgs = pkgs.extend default.overlays.default;
      sources = {
        inputs = sources;
        modules = default.nixos-modules;
        examples = lib.mapAttrs (
          _: project: lib.mapAttrs (_: example: example.module) project.nixos.examples
        ) self.hydrated-projects;
      };
    };

    inherit (self.project-utils)
      checks
      projects
      hydrated-projects
      ;

    demo-utils = self.import ./overview/demo {
      ngipkgs-modules = lib.attrValues (lib.flattenAttrs "." self.nixos-modules);
    };

    inherit (self.demo-utils)
      # for demo code activation. used in the overview code snippets
      demo-shell
      demo-vm
      # - $(nix-build -A demos.PROJECT_NAME)
      # - nix run .#demos.PROJECT_NAME
      demos
      ;

    metrics = self.import ./maintainers/metrics.nix {
      raw-projects = self.hydrated-projects;
    };

    report = self.import ./maintainers/report { };
  });
in
default
# required for update scripts
// default.ngipkgs
