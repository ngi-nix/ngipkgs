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

  extension = import ./pkgs/lib.nix { inherit lib sources; };
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

  overview = import ./overview {
    inherit lib;
    projects = evaluated-modules.config.projects;
    self = flake;
    pkgs = pkgs.extend overlays.default;
    options = optionsDoc.optionsNix;
  };

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit (evaluated-modules) options;
  };

  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix mkSbtDerivation;
    };

  examples =
    with lib;
    mapAttrs (_: project: mapAttrs (_: example: example.module) project.nixos.examples) projects;

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
    // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues projects));

  extendedNixosModules =
    let
      ngipkgsModules = lib.attrValues (lib.flattenAttrs "." nixos-modules);
      nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";
    in
    nixosModules ++ ngipkgsModules;

  evaluated-modules = lib.evalModules {
    class = "nixos";
    modules = [
      {
        nixpkgs.hostPlatform = {
          inherit system;
        };

        networking = {
          domain = "invalid";
          hostName = "options";
        };

        # faster eval time
        documentation.nixos.enable = false;
        documentation.man.generateCaches = false;

        system.stateVersion = "23.05";
      }
      ./overview/demo/shell.nix
      raw-projects # for checks
    ]
    ++ extendedNixosModules;
    specialArgs = {
      modulesPath = "${sources.nixpkgs}/nixos/modules";
    };
  };

  # recursively evaluates each attribute for all projects
  eval-projects = lib.forceEvalRecursive evaluated-modules.config.projects;

  checks = lib.mapAttrs (
    name: value: pkgs.writeText "${name}-eval-check" (lib.strings.toJSON value)
  ) eval-projects;

  ngipkgs = import ./pkgs/by-name {
    inherit
      pkgs
      lib
      dream2nix
      mkSbtDerivation
      ;
  };

  raw-projects = import ./projects {
    inherit lib system;
    pkgs = pkgs.extend overlays.default;
    sources = {
      inputs = sources;
      modules = nixos-modules;
      inherit examples;
    };
  };

  projects = make-projects raw-projects.config.projects;

  # TODO: find a better place for this
  make-projects =
    projects:
    with lib;
    let
      empty-if-null = x: if x != null then x else { };

      hydrate =
        # we use fields to track state of completion.
        # - `null` means "expected but missing"
        # - not set means "not applicable"
        # TODO: encode this in types, either yants or the module system
        project: rec {
          metadata = empty-if-null (filterAttrs (_: m: m != null) (project.metadata or { }));
          nixos.demo = filterAttrs (_: m: m != null) (empty-if-null (project.nixos.demo or { }));
          nixos.modules.services = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.services or { }
          );
          nixos.modules.programs = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.programs or { }
          );
          # TODO: access examples for services and programs separately?
          nixos.examples = lib.filterAttrs (name: example: example.module != null) (
            (empty-if-null (project.nixos.examples or { }))
            // (filter-map (project.nixos.modules.programs or { }) "examples")
            // (filter-map (project.nixos.modules.services or { }) "examples")
          );
          nixos.tests = import ./projects/tests.nix {
            inherit lib pkgs project;
            inherit (nixos) examples;
          };
        };
    in
    mapAttrs (name: project: hydrate project) projects;

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
    raw-projects = evaluated-modules.config.projects;
  };

  project-demos = lib.filterAttrs (name: value: value != null) (
    lib.mapAttrs (
      name: value: value.nixos.demo.vm or value.nixos.demo.shell or null
    ) evaluated-modules.config.projects
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
