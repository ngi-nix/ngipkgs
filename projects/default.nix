{
  lib,
  pkgs ? {},
  sources,
}: let
  inherit
    (builtins)
    elem
    readDir
    trace
    ;

  inherit
    (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  baseDirectory = ./.;

  projectDirectories = let
    names = name: type:
      if type == "directory"
      then {${name} = baseDirectory + "/${name}";}
      # nothing else should be kept in this directory reserved for projects
      else assert elem name allowedFiles; {};
    allowedFiles = ["README.md" "default.nix"];
  in
    concatMapAttrs names (readDir baseDirectory);

  hydrate = let
    empty-if-null = x:
      if x != null
      then x
      else {};
  in
    # we use fields to track state of completion.
    # - `null` means "expected but missing"
    # - not set means "not applicable"
    project: {
      packages = empty-if-null (project.packages or {});
      nixos.modules = empty-if-null (project.nixos.modules or {});
      nixos.examples = empty-if-null (project.nixos.examples or {});
      nixos.tests = empty-if-null (project.nixos.tests or {});
    };
in
  mapAttrs
  (
    name: directory: let
      project = import directory {inherit lib pkgs sources;};
    in
      if project.broken or false
      then trace "Skipping project '${name}' which is marked as broken for system '${pkgs.system or "undefined"}'." {}
      else hydrate project
  )
  projectDirectories
