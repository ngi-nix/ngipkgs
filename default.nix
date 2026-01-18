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
    overlays = import ./pkgs/overlays.nix { inherit lib; };
    inherit system;
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
let
  devLib = import ./pkgs/lib.nix { inherit lib sources system; };

  flakeAttrs = default.import ./maintainers/flake { };

  default = devLib.customScope pkgs.newScope (self: {
    lib = lib.extend self.overlays.devLib;

    inherit
      devLib
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

      devLib = _: _: devLib;

      fixups = self.call ./pkgs/overlays.nix { };
    };

    formatter = self.call ./maintainers/formatter.nix { };

    overview = self.import ./overview {
      self = flake;
      pkgs = pkgs.extend self.overlays.default;
      options = self.optionsDoc.optionsNix;
      projects = self.project-utils.projects;
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
        demos = lib.mapAttrs (
            _: project: lib.filterAttrs (_: v: v != null) {
              vm = project.nixos.demo.vm.module or null;
              shell = project.nixos.demo.shell.module or null;
            }
          ) self.hydrated-projects;
      };
    };

    inherit (self.project-utils)
      checks
      hydrated-projects
      optionsDoc
      ;

    projects = lib.mapAttrs (name: value: {
      tests = value.nixos.tests;
      demo = default.demos.${name} or null;
      module-check = default.checks.${name};
    }) self.hydrated-projects;

    tests = lib.mapAttrs (_: value: value.nixos.tests) self.hydrated-projects;

    demo-utils = self.import ./overview/demo {
      ngipkgs-modules = lib.attrValues (devLib.flattenAttrs "." self.nixos-modules);
      projects = self.project-utils.projects;
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
