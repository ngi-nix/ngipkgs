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
  # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
    {
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      ngipkgs = {...}: {
        nixpkgs.overlays = [overlays.default];
      };
    }
    // foldl recursiveUpdate {}
    (map (project: filterAttrs (_: m: m != null) project.nixos.modules) (attrValues projects));

  ngipkgs = import ./pkgs/by-name {inherit pkgs lib dream2nix;};

  raw-projects = import ./projects {
    inherit lib;
    pkgs = pkgs // ngipkgs;
    sources = {
      inputs = sources;
      # TODO: sops-nix is needed only for Pretalx and Rosenpass, and they can get it from `sources`
      modules = nixos-modules // {inherit sops-nix;};
      inherit examples;
    };
  };

  # TODO: find a better place for this
  metrics = with lib; {
    projects = attrNames raw-projects;
    in-ngipkgs = attrNames ngipkgs;
    derivations = concatMap (p: attrNames p.packages) (attrValues raw-projects);
    with-services = attrNames (filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects);
    missing-services = attrNames (filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services == null) raw-projects);
    services = concatMap attrNames (
      concatMap (p: attrValues p.nixos.modules)
      (attrValues (filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects))
    );
    with-tests = attrNames (filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects);
    missing-tests = attrNames (filterAttrs (name: p: p ? nixos.tests && p.nixos.tests == null) raw-projects);
    tests = concatMap (p: attrNames p.nixos.tests) (attrValues (filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects));
    with-examples = attrNames (filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects);
    missing-examples = attrNames (filterAttrs (name: p: p ? nixos.examples && p.nixos.examples == null) raw-projects);
    examples = concatMap (p: attrNames p.nixos.examples) (attrValues (filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects));
  };

  metrics-count = with lib; mapAttrs (name: value: count (_: true) value) metrics;

  project-metrics = with lib;
    mapAttrs
    (
      _: p:
        {
          derivations = count (_: true) (attrNames p.packages);
        }
        // optionalAttrs (p ? nixos)
        {
          nixos =
            {
              tests =
                if p.nixos.tests == null
                then 0
                else count (_: true) (attrNames p.nixos.tests);
              examples =
                if p.nixos.examples == null
                then 0
                else count (_: true) (attrNames p.nixos.examples);
            }
            // optionalAttrs (p ? nixos.modules.services) {
              services =
                if p.nixos.modules.services == null
                then 0
                else count (_: true) (attrNames p.nixos.modules.services);
            }
            // optionalAttrs (p ? nixos.modules.programs) {
              programs =
                if p.nixos.modules.programs == null
                then 0
                else count (_: true) (attrNames p.nixos.modules.programs);
            };
        }
    )
    raw-projects;

  # TODO: find a better place for this
  projects = with lib; let
    nixosTest = test: let
      # Amenities for interactive tests
      tools = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [vim tmux jq];
        # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
        # to provide a slightly nicer console.
        # kmscon allows zooming with [Ctrl] + [+] and [Ctrl] + [-]
        services.kmscon = {
          enable = true;
          autologinUser = "root";
        };
      };
      debugging.interactive.nodes = mapAttrs (_: _: tools) test.nodes;
    in
      pkgs.nixosTest (debugging // test);

    empty-if-null = x:
      if x != null
      then x
      else {};

    hydrate =
      # we use fields to track state of completion.
      # - `null` means "expected but missing"
      # - not set means "not applicable"
      # TODO: encode this in types, either yants or the module system
      project: {
        packages = empty-if-null (filterAttrs (name: value: value != null) (project.packages or {}));
        nixos.modules = empty-if-null (project.nixos.modules or {});
        nixos.examples = empty-if-null (project.nixos.examples or {});
        nixos.tests =
          mapAttrs
          (
            _: test:
              if lib.isString test
              then
                (import test {
                  inherit pkgs;
                  inherit (pkgs) system;
                })
              else nixosTest test
          )
          (empty-if-null (project.nixos.tests or {}));
      };
  in
    mapAttrs (name: project: hydrate project) raw-projects;

  shell = pkgs.mkShellNoCC {
    packages = [];
  };
}
