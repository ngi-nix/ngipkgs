{
  lib,
  pkgs,
  sources,
  models ? import ./models.nix {
    inherit lib pkgs;
    sources = sources.inputs;
  },
}:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    filterAttrs
    filterAttrsRecursive
    ;

  inherit (models)
    project
    ;

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
        "models.nix"
        "test.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);

  projects =
    let
      nixosTest = import ./test.nix { inherit lib pkgs; };
      empty-if-null = x: if x != null then x else { };
      concat-map = attrs: input: lib.concatMapAttrs (_: value: value."${input}" or { }) attrs;

      hydrate =
        # we use fields to track state of completion.
        # - `null` means "expected but missing"
        # - not set means "not applicable"
        # TODO: encode this in types, either yants or the module system
        project: rec {
          metadata = project.metadata or { };
          # TODO: use the evaluated modules in the overview and remove these
          nixos.modules.services = lib.mapAttrs (
            name: value: value.module or null
          ) project.nixos.modules.services or { };
          nixos.modules.programs = lib.mapAttrs (
            name: value: value.module or null
          ) project.nixos.modules.programs or { };
          # TODO: access examples for services and programs separately?
          nixos.examples =
            (empty-if-null (project.nixos.examples or { }))
            // (concat-map (project.nixos.modules.programs or { }) "examples")
            // (concat-map (project.nixos.modules.services or { }) "examples");
          nixos.tests = mapAttrs (
            _: test:
            if lib.isString test then
              (import test {
                inherit pkgs;
                inherit (pkgs) system;
              })
            else if lib.isDerivation test then
              test
            else if builtins.isNull test then
              null # will be filtered, later
            else
              nixosTest test
          ) ((empty-if-null project.nixos.tests or { }) // (concat-map (nixos.examples or { }) "tests"));
        };
    in
    filterAttrsRecursive (n: v: v != null) (mapAttrs (name: project: hydrate project) raw-projects);

  raw-projects = mapAttrs (
    name: directory: project (import directory { inherit lib pkgs sources; })
  ) projectDirectories;
in
{
  inherit
    projects
    raw-projects
    ;
}
