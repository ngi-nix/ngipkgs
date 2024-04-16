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
    mapAttrs
    recursiveUpdate
    filterAttrs
    ;

  baseDirectory = ./.;

  allowedFiles = ["README.md" "default.nix"];

  isMarkedBroken = project: project.broken or false;

  filter = name: type:
    if type != "directory"
    then assert elem name allowedFiles; false
    else true;

  hydrate = project:
    recursiveUpdate
    project
    {nixos.tests = mapAttrs (_: pkgs.nixosTest) project.nixos.tests or {};};
in
  mapAttrs (
    name: type: let
      project = import (baseDirectory + "/${name}") {
        inherit lib pkgs sources;
      };
    in
      if isMarkedBroken project
      then trace "Project '${name}' marked as broken (for system '${pkgs.system or "undefined"}'). Skipping." {}
      else hydrate project
  ) (filterAttrs filter (readDir baseDirectory))
