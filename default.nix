let
  flake-inputs = import (
    fetchTarball "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0"
  );
  inherit (flake-inputs)
    import-flake
    ;
in
{
  flake ? import-flake {
    src = ./.;
  },
  sources ? flake.inputs,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
let
  dream2nix = (import sources.dream2nix).overrideInputs { inherit (sources) nixpkgs; };
  mkSbtDerivation =
    x:
    import sources.sbt-derivation (
      x
      // {
        inherit pkgs;
        overrides = {
          sbt = pkgs.sbt.override {
            jre = pkgs.jdk17_headless;
          };
        };
      }
    );

  extension = import ./pkgs/lib.nix { inherit lib sources system; };
  extended = lib.extend (_: _: extension);
in
rec {
  lib = extended;

  inherit
    pkgs
    system
    sources
    extension
    ;

  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix mkSbtDerivation;
    };

  ngipkgs = import ./pkgs/by-name {
    inherit
      pkgs
      lib
      dream2nix
      mkSbtDerivation
      ;
  };

  examples =
    with lib;
    mapAttrs (
      _: project: mapAttrs (_: example: example.module) project.nixos.examples
    ) hydrated-projects;

  nixos-modules =
    with lib;
    # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
    {
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      ngipkgs =
        { ... }:
        {
          nixpkgs.overlays = [ overlays.default ];
        };
    }
    // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues hydrated-projects));

  extendedNixosModules =
    let
      ngipkgsModules = lib.attrValues (lib.flattenAttrs "." nixos-modules);
      nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";
    in
    nixosModules ++ ngipkgsModules;

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

  inherit
    (import ./projects {
      inherit lib system;
      pkgs = pkgs.extend overlays.default;
      sources = {
        inputs = sources;
        modules = nixos-modules;
        inherit examples;
      };
    })
    checks
    projects
    hydrated-projects
    ;

  shell = pkgs.mkShellNoCC {
    packages = [
      # live overview watcher
      (pkgs.devmode.override {
        buildArgs = "-A overview --show-trace -v";
      })

      (pkgs.writeShellApplication {
        # TODO: have the program list available tests
        name = "ngipkgs-test";
        text = ''
          export pr="$1"
          export proj="$2"
          export test="$3"
          # remove the first args and feed the rest (for example flags)
          export args="''${*:4}"

          nix build --override-input nixpkgs "github:NixOS/nixpkgs?ref=pull/$pr/merge" .#checks.x86_64-linux.projects/"$proj"/nixos/tests/"$test" "$args"
        '';
      })
    ];
  };

  metrics = import ./maintainers/metrics.nix {
    inherit
      lib
      pkgs
      ngipkgs
      ;
    raw-projects = projects;
  };

  project-demos = lib.filterAttrs (name: value: value != null) (
    lib.mapAttrs (name: value: value.nixos.demo.vm or value.nixos.demo.shell or null) projects
  );

  demo = import ./overview/demo {
    inherit
      lib
      pkgs
      sources
      system
      ;
    demo-modules = lib.flatten (
      lib.mapAttrsToList (name: value: value.module-demo.imports) project-demos
    );
    nixos-modules = extendedNixosModules;
  };

  inherit (demo)
    demo-vm
    demo-shell
    ;
}
