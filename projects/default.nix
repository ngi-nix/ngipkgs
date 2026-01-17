{
  lib,
  pkgs,
  sources,
  system,

  nixos-modules,
  ...
}@args:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  types = import ./types.nix { inherit lib; };

  baseDirectory = ./.;

  projectDirectories =
    let
      names =
        name: type:
        if type == "directory" then
          { ${name} = baseDirectory + "/${name}"; }
        # nothing else should be kept in this directory reserved for projects
        else
          assert elem name allowedFiles;
          { };
      allowedFiles = [
        "README.md"
        "default.nix"
        "tests.nix"
        "types.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);
in
rec {
  raw-projects = {
    options.projects = types.options.projects;
    config.projects = mapAttrs (name: directory: import directory args) projectDirectories;
  };

  eval-projects = lib.evalModules {
    modules = [
      raw-projects
    ];
    specialArgs.modulesPath = "${sources.inputs.nixpkgs}/nixos/modules";
  };

  projects = eval-projects.config.projects;

  # Force recursive evaluation for all projects
  checks = lib.mapAttrs (
    name: value: pkgs.writeText "${name}-eval-check" (lib.strings.toJSON value)
  ) (lib.forceEvalRecursive projects);

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit
      (lib.evalModules {
        modules = [
          {
            # Don't check because NixOS options are not included.
            # See comment in NixOS' `noCheckForDocsModule`.
            config._module.check = false;

            config.nixpkgs.hostPlatform = system;
            config._module.args.pkgs = pkgs;

            imports = lib.pipe nixos-modules [
              (lib.filterAttrs (_: value: lib.isAttrs value))
              (lib.mapAttrsToList (name: value: lib.attrValues value))
              (lib.flatten)
            ];
          }
        ];
        specialArgs.modulesPath = "${sources.inputs.nixpkgs}/nixos/modules";
      })
      options
      ;
  };

  # TODO: no longer useful. refactor whatever needs this and remove.
  hydrated-projects =
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
          nixos.tests = import ./tests.nix {
            inherit lib pkgs project;
            inherit (nixos) examples;
          };
        };
    in
    mapAttrs (name: hydrate) raw-projects.config.projects;
}
