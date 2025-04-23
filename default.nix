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

  # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
  ngipkgs-modules = {
    # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
    ngipkgs =
      { ... }:
      {
        nixpkgs.overlays = [ overlays.default ];
      };
    services = lib.foldl lib.recursiveUpdate { } (
      map (
        project: (lib.mapAttrs (_: value: value.module or null) project.nixos.modules.services or { })
      ) (lib.attrValues raw-projects)
    );
    programs = lib.foldl lib.recursiveUpdate { } (
      map (
        project: (lib.mapAttrs (_: value: value.module or null) project.nixos.modules.programs or { })
      ) (lib.attrValues raw-projects)
    );
  };

  ngipkgsModules = lib.filter (m: m != null) (
    lib.mapAttrsToList (name: value: value) ngipkgs-modules.services
    ++ lib.mapAttrsToList (name: value: value) ngipkgs-modules.programs
  );

  nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";

  extendedNixosModules =
    [
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      {
        nixpkgs.overlays = [ overlays.default ];
      }
      # TODO: needed for examples that use sops (like Pretalx)
      sops-nix
    ]
    ++ nixosModules
    ++ ngipkgsModules;

  evaluated-modules = lib.evalModules {
    modules = [
      {
        nixpkgs.hostPlatform = { inherit system; };

        networking = {
          domain = "invalid";
          hostName = "options";
        };

        system.stateVersion = "23.05";
      }
    ] ++ extendedNixosModules;
    specialArgs = {
      modulesPath = "${sources.nixpkgs}/nixos/modules";
    };
  };

  ngipkgs = import ./pkgs/by-name { inherit pkgs lib dream2nix; };

  # TODO: cleanup
  inherit
    (
      (import ./projects {
        inherit lib;
        pkgs = pkgs // ngipkgs;
        sources = {
          inputs = sources;
          modules = ngipkgs-modules;
          inherit examples;
        };
      })
    )
    raw-projects
    projects
    ;

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
