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

  # TODO: refactor and handle attrs inside
  ngipkgs-modules = lib.flatten (
    lib.mapAttrsToList (
      _: project:
      (lib.mapAttrsToList (_: value: value.module or { }) project.nixos.modules.services or { })
      ++ (lib.mapAttrsToList (_: value: value.module or { }) project.nixos.modules.programs or { })
    ) raw-projects
  );

  # TODO: cleanup
  nixosModules = import "${sources.nixpkgs}/nixos/modules/module-list.nix";
  extendedNixosModules =
    with lib;
    [
      nixos-modules.ngipkgs
      # TODO: needed for examples that use sops (like Pretalx)
      sops-nix
    ]
    ++ attrValues nixos-modules.programs
    ++ attrValues nixos-modules.services;
  evaluated-modules = lib.evalModules {
    modules =
      [
        {
          nixpkgs.hostPlatform = { inherit system; };
        }
      ]
      ++ nixosModules
      ++ extendedNixosModules;
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
          modules = nixos-modules;
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
