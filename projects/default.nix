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
    filterAttrs
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
      packages = empty-if-null (filterAttrs (name: value: value != null) (project.packages or {}));
      nixos.modules = empty-if-null (project.nixos.modules or {});
      nixos.examples = empty-if-null (project.nixos.examples or {});
      nixos.tests =
        mapAttrs
        (
          _: test:
            if lib.isString test
            then
              (import test {
                inherit pkgs;
                inherit (pkgs) system;
              })
            else nixosTest test
        )
        (empty-if-null (project.nixos.tests or {}));
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
