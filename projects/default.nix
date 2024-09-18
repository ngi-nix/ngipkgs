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

  hydrate = project:
    recursiveUpdate
    project
    {nixos.tests = mapAttrs (_: nixosTest) project.nixos.tests or {};};
in
  mapAttrs (
    name: type: let
      project = import (baseDirectory + "/${name}") {
        inherit lib pkgs sources;
      };
    in
      if isMarkedBroken project
      then trace "Skipping project '${name}' which is marked as broken for system '${pkgs.system or "undefined"}'." {}
      else hydrate project
  ) (filterAttrs filter (readDir baseDirectory))
