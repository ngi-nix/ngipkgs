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

  hydrate = project: {
    packages = project.packages or {};
    nixos.modules = project.nixos.modules or {};
    nixos.examples = project.nixos.examples or {};
    nixos.tests = project.nixos.tests or {};
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
