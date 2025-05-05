{
  sources ? import (fetchTarball "https://github.com/fricklerhandwerk/flake-inputs/tarball/main") {
    root = ./.;
  },
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
  sops-nix = import "${sources.sops-nix}/modules/sops";
in
rec {
  inherit
    lib
    pkgs
    system
    sources
    ;

  # TODO: we should be exporting our custom functions as `lib`, but refactoring
  # this to use `pkgs.lib` everywhere is a lot of movement
  lib' = {
    # Take an attrset of arbitrary nesting and make it flat
    # by concatenating the nested names with the given separator.
    flattenAttrs =
      separator:
      let
        f = path: lib.concatMapAttrs (flatten path);
        flatten =
          path: name: value:
          if lib.isAttrs value then f (path + name + separator) value else { ${path + name} = value; };
      in
      f "";

    # get the path of NixOS module from string
    # example:
    # lib'.moduleLocFromOptionString "services.ntpd-rs"
    # => "/nix/store/...-source/nixos/modules/services/networking/ntp/ntpd-rs.nix"
    moduleLocFromOptionString =
      let
        inherit
          (lib.evalModules {
            class = "nixos";
            specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
            modules = [
              ({
                config = {
                  _module.check = false;
                  nixpkgs.hostPlatform = if builtins.isNull system then builtins.currentSystem else system;
                };
              })
            ] ++ import "${sources.nixpkgs}/nixos/modules/module-list.nix";
          })
          options
          ;
      in
      opt:
      let
        locList = lib.splitString "." opt;
        optAttrs = lib.getAttrFromPath locList options;

        # collect all file paths from all options
        collectFiles =
          attrs:
          let
            # get value of `files` attr or empty list
            getFiles =
              attr: if attr.value ? files && builtins.isList attr.value.files then attr.value.files else [ ];
          in
          lib.concatMap getFiles (lib.attrsToList attrs);
      in
      lib.head (collectFiles optAttrs);
  };

  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix;
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
    with lib;
    [
      nixos-modules.ngipkgs
      # TODO: needed for examples that use sops (like Pretalx)
      sops-nix
    ]
    ++ attrValues nixos-modules.programs
    ++ attrValues nixos-modules.services;

  ngipkgs = import ./pkgs/by-name { inherit pkgs lib dream2nix; };

  raw-projects = import ./projects {
    inherit lib;
    pkgs = pkgs // ngipkgs;
    sources = {
      inputs = sources;
      modules = nixos-modules;
      inherit examples;
    };
  };

  # TODO: remove after migrating to modules
  # ===

  raw-projects-modules = import ./projects/default-module.nix {
    inherit lib;
    pkgs = pkgs // ngipkgs;
    sources = {
      inputs = sources;
      modules = nixos-modules;
      inherit examples;
    };
  };

  # TODO: delete the file after migrating to modules
  projects-modules = make-projects raw-projects-modules.config.projects;

  # TODO:
  # ===

  project-models = import ./projects/models.nix { inherit lib pkgs sources; };

  # we mainly care about the types being checked
  templates.project =
    let
      project-metadata =
        (project-models.project (import ./maintainers/templates/project { inherit lib pkgs sources; }))
        .metadata;
    in
    # fake derivation for flake check
    pkgs.writeText "dummy" (lib.strings.toJSON project-metadata);

  # TODO: find a better place for this
  make-projects =
    projects:
    with lib;
    let
      nixosTest =
        test:
        let
          # Amenities for interactive tests
          tools =
            { pkgs, ... }:
            {
              environment.systemPackages = with pkgs; [
                vim
                tmux
                jq
              ];
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

      empty-if-null = x: if x != null then x else { };
      filter-map =
        attrs: input:
        lib.pipe attrs [
          (lib.concatMapAttrs (_: value: value."${input}" or { }))
          (lib.filterAttrs (_: v: v != null))
        ];

      hydrate =
        # we use fields to track state of completion.
        # - `null` means "expected but missing"
        # - not set means "not applicable"
        # TODO: encode this in types, either yants or the module system
        project: rec {
          metadata = empty-if-null (filterAttrs (_: m: m != null) (project.metadata or { }));
          nixos.modules.services = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.services or { }
          );
          nixos.modules.programs = filterAttrs (_: m: m != null) (
            lib.mapAttrs (name: value: value.module or null) project.nixos.modules.programs or { }
          );
          # TODO: access examples for services and programs separately?
          nixos.examples =
            (empty-if-null (project.nixos.examples or { }))
            // (filter-map (project.nixos.modules.programs or { }) "examples")
            // (filter-map (project.nixos.modules.services or { }) "examples");
          nixos.tests = mapAttrs (
            _: test:
            if lib.isString test then
              (import test {
                inherit pkgs;
                inherit (pkgs) system;
              })
            else if lib.isDerivation test then
              test
            else
              nixosTest test
          ) ((empty-if-null project.nixos.tests or { }) // (filter-map (nixos.examples or { }) "tests"));
        };
    in
    mapAttrs (name: project: hydrate project) projects;

  projects = make-projects raw-projects;

  shell = pkgs.mkShellNoCC {
    packages = [ ];
  };

  demo = import ./overview/demo {
    inherit
      lib
      pkgs
      sources
      extendedNixosModules
      ;
  };
}
