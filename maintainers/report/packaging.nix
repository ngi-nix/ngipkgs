{
  lib,
  pkgs,
  metrics,
  ...
}:
let
  # previous version of NGIpkgs to compare against
  prev-rev = "40be4af909abc7e0e11ab45b90f34c8f8714aa56"; # 24.09
  prev-ngipkgs = import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/${prev-rev}") { };
  prev-date =
    let
      sub = start: len: lib.substring start len base-flake.lastModifiedDate;
      base-flake = builtins.getFlake "github:ngi-nix/ngipkgs/${prev-rev}";
    in
    "${sub 0 4}-${sub 4 2}-${sub 6 2}";

  prev-project-names = lib.attrNames prev-ngipkgs.projects;
  current-project-names = metrics.metrics.projects;

  # get links for newly added projects
  project-names = lib.filter (x: !lib.elem x prev-project-names) current-project-names;
  project-links = lib.concatMapStringsSep "\n" (
    name:
    let
      subgrant-count =
        project:
        toString (
          lib.mapAttrsToList (
            subgrant: count: "\n    - ${subgrant}: ${toString count}"
          ) metrics.project-metrics.${project}.metadata.subgrants
        );
    in
    "  - [${name}](https://ngi.nixos.org/project/${name})" + subgrant-count name
  ) project-names;

  # metrics
  nixos = lib.mapAttrsRecursive (path: toString) metrics.summary.nixos;
  nixpkgs = lib.mapAttrsRecursive (path: toString) metrics.summary.nixpkgs;
  ngipkgs = lib.mapAttrsRecursive (path: toString) metrics.summary.ngipkgs;
  prev-project-count = toString (lib.length prev-project-names);
in
pkgs.writeText "report-packaging.md" ''
  - Start date: ${prev-date}
  - Projects count at the start: ${prev-project-count}
  - Projects count at the end: ${ngipkgs.projects}

  ## Projects
  ${project-links}

  ## Metrics
  ### NGIpkgs (monorepo)
    - ${ngipkgs.derivations} package derivations, ${ngipkgs.update-scripts} of which have an explicit update script
    - ${nixos.services} services and ${nixos.programs} programs
    - ${nixos.tests} NixOS tests, associated with ${nixos.examples} examples
    - ${nixos.demos} projects have a demo available
    - Subgrants
      - ${ngipkgs.metadata.subgrants.Commons} Commons
      - ${ngipkgs.metadata.subgrants.Core} Core
      - ${ngipkgs.metadata.subgrants.Entrust} Entrust
      - ${ngipkgs.metadata.subgrants.Review} Review

  ### Nixpkgs (upstream)
    - Maintaining ${nixpkgs.derivations} package derivations in upstream Nixpkgs, ${nixpkgs.update-scripts} of which have an explicit update script
''
