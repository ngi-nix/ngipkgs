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
  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix mkSbtDerivation;
    };

  # apply package fixes
  overlays.fixups = import ./pkgs/overlays.nix { inherit lib; };
    ngipkgs = self.import ./pkgs/by-name { };

    shell = self.import ./maintainers/shells/default.nix { };

  nixos-modules =
    with lib;
    # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
    {
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      ngipkgs =
        { ... }:
        {
          nixpkgs.overlays = [ overlays.default ] ++ overlays.fixups;
        };
    }
    // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues hydrated-projects));

  overview = import ./overview {
    inherit lib projects;
    self = flake;
    pkgs = pkgs.extend overlays.default;
    options = optionsDoc.optionsNix;
  };

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit
      (lib.evalModules {
        modules = [
          {
            nixpkgs.hostPlatform = system;

            networking = {
              domain = "invalid";
              hostName = "options";
            };

            system.stateVersion = "23.05";
          }
          ./overview/demo/shell.nix
        ]
        ++ extendedNixosModules;
        specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
      })
      options
      ;
  };

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
      ngipkgs-modules = lib.attrValues (devLib.flattenAttrs "." self.nixos-modules);
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
