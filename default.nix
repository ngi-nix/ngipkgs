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

  extension = rec {
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

    # Recursively evaluate attributes for an attribute set.
    # Coupled with an evaluated nixos configuration, this presents an efficient
    # way for checking module types.
    forceEvalRecursive =
      attrs:
      lib.mapAttrsRecursive (
        n: v:
        if lib.isList v then
          map (
            i:
            # if eval fails
            if !(builtins.tryEval i).success then
              # recursively recurse into attrsets
              if lib.isAttrs i then forceEvalRecursive i else (builtins.tryEval i).success
            else
              (builtins.tryEval i).success
          ) v
        else
          (builtins.tryEval v).success
      ) attrs;

    # get the path of NixOS module from string
    # example:
    # moduleLocFromOptionString "services.ntpd-rs"
    # => "/nix/store/...-source/nixos/modules/services/networking/ntp/ntpd-rs.nix"
    moduleLocFromOptionString =
      let
        inherit
          (lib.evalModules {
            class = "nixos";
            specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
            modules = [
              {
                config = {
                  # remove this after nixpkgs is separated: https://github.com/ngi-nix/ngipkgs/pull/968#discussion_r2067929098
                  # nixpkgs.hostPlatform = if builtins.isNull system then builtins.currentSystem else system;
                  nixpkgs.hostPlatform = builtins.currentSystem or "x86_64-linux";
                };
              }
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

  extended = lib.extend (_: _: extension);
in
rec {
  lib = extended;
  inherit extension;

  inherit
    pkgs
    system
    sources
    ;

  overview = import ./overview {
    inherit
      lib
      system
      projects
      ;
    self = flake;
    pkgs = pkgs // ngipkgs;
    options = optionsDoc.optionsNix;
  };

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit (evaluated-modules) options;
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
          # TODO: properly separate the demo modules from production code
          imports = [ ./overview/demo/shell.nix ];
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
        nixpkgs.hostPlatform = { inherit system; };

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
    ] ++ extendedNixosModules;
    specialArgs = {
      modulesPath = "${sources.nixpkgs}/nixos/modules";
    };
  };

  # recursively evaluates each attribute for all projects
  check-projects = lib.forceEvalRecursive evaluated-modules.config.projects;

  ngipkgs = import ./pkgs/by-name { inherit pkgs lib dream2nix; };

  raw-projects = import ./projects {
    inherit lib system;
    pkgs = pkgs // ngipkgs;
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
          args = debugging // test;
        in
        if lib.isDerivation test then test else pkgs.nixosTest args;

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
          nixos.demo = filterAttrs (_: m: m != null) (empty-if-null (project.nixos.demo or { }));
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
              nixosTest (
                import test {
                  inherit pkgs lib;
                  inherit (pkgs) system;
                }
              )
            else
              nixosTest test
          ) ((empty-if-null project.nixos.tests or { }) // (filter-map (nixos.examples or { }) "tests"));
        };
    in
    mapAttrs (name: project: hydrate project) projects;

  shell = pkgs.mkShellNoCC {
    packages = [
      # live overview watcher
      (pkgs.devmode.override {
        buildArgs = "-A overview --show-trace";
      })
    ];
  };

  demo = import ./overview/demo {
    inherit
      lib
      pkgs
      sources
      extendedNixosModules
      system
      ;
  };

  inherit (demo)
    demo-vm
    demo-shell
    ;
}
