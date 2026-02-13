{
  lib,
  pkgs,
  metrics,
  # Optional: set to a commit hash to compare against previous state
  prev-rev ? null,
  ...
}:
let
  current-project-names = metrics.metrics.projects;

  # Only fetch previous state if prev-rev is provided
  hasPrevious = prev-rev != null;
  prev-ngipkgs =
    if hasPrevious then
      import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/${prev-rev}") { }
    else
      null;
  prev-date =
    if hasPrevious then
      let
        sub = start: len: lib.substring start len base-flake.lastModifiedDate;
        base-flake = builtins.getFlake "github:ngi-nix/ngipkgs/${prev-rev}";
      in
      "${sub 0 4}-${sub 4 2}-${sub 6 2}"
    else
      null;
  prev-project-names = if hasPrevious then lib.attrNames prev-ngipkgs.projects else [ ];
  prev-project-count = if hasPrevious then toString (lib.length prev-project-names) else null;

  # Get links for newly added projects (or all projects if no previous state)
  project-names =
    if hasPrevious then
      lib.filter (x: !lib.elem x prev-project-names) current-project-names
    else
      current-project-names;

  project-links = lib.concatMapStringsSep "\n" (
    name:
    let
      subgrants = metrics.project-metrics.${name}.metadata.subgrants or { };
      subgrant-list =
        if subgrants == { } then
          ""
        else
          "\n    - Subgrants: " + (lib.concatStringsSep ", " (lib.attrNames subgrants));
    in
    "  - ${name}\n    - URL: https://ngi.nixos.org/project/${name}${subgrant-list}"
  ) project-names;

  # metrics
  nixos = lib.mapAttrsRecursive (path: toString) metrics.summary.nixos;
  nixpkgs = lib.mapAttrsRecursive (path: toString) metrics.summary.nixpkgs;
  ngipkgs = lib.mapAttrsRecursive (path: toString) metrics.summary.ngipkgs;

  # Generate header based on whether we have previous state
  header =
    if hasPrevious then
      ''
        - Start date: ${prev-date}
        - Projects count at the start: ${prev-project-count}
        - Projects count at the end: ${ngipkgs.projects}
      ''
    else
      ''
        - Total projects: ${ngipkgs.projects}
      '';
in
pkgs.writeText "report-packaging.md" ''
  ${header}

  ## Projects
  ${project-links}

  ## Metrics
  ### NGIpkgs (monorepo)
    - ${ngipkgs.derivations} package derivations with ${ngipkgs.update-scripts} update scripts
    - ${nixos.services} services and ${nixos.programs} programs
    - ${nixos.tests} NixOS tests with ${nixos.examples} examples
    - ${nixos.demos} projects with demo
    - Subgrants
      - ${ngipkgs.metadata.subgrants.Commons} Commons
      - ${ngipkgs.metadata.subgrants.Core} Core
      - ${ngipkgs.metadata.subgrants.Entrust} Entrust
      - ${ngipkgs.metadata.subgrants.Review} Review

  ### Nixpkgs (upstream)
    - ${nixpkgs.derivations} package derivations with ${nixpkgs.update-scripts} update scripts
''
