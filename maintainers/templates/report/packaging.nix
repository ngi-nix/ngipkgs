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
      hasDemo = metrics.project-metrics.${name}.nixos.demos != 0;
    in
    "  - [${name}](https://ngi.nixos.org/project/${name}/${lib.optionalString hasDemo "#demo"})"
  ) project-names;

  # metrics
  nixos = lib.mapAttrsRecursive (path: toString) metrics.summary.nixos;
  ngipkgs = lib.mapAttrsRecursive (path: toString) metrics.summary.ngipkgs;
  prev-project-count = toString (lib.length prev-project-names);
in
pkgs.writeText "report-packaging" ''
  - Worked on supporting ${ngipkgs.projects} NGI-funded projects (${prev-date}: ${prev-project-count})
  ${project-links}
  - NGIpkgs (monorepo)
    - Metrics
      - ${nixos.demos} projects have a demo, available
      - ${nixos.services} services and ${nixos.programs} programs
      - ${nixos.tests} NixOS tests, associated with ${nixos.examples} examples
      - ${ngipkgs.derivations} derivations, ${ngipkgs.update-scripts} of which have an explicit update script
      - Subgrants
        - ${ngipkgs.metadata.subgrants.Commons} Commons
        - ${ngipkgs.metadata.subgrants.Core} Core
        - ${ngipkgs.metadata.subgrants.Entrust} Entrust
        - ${ngipkgs.metadata.subgrants.Review} Review
        - ${ngipkgs.metadata.subgrants.Uncategorized} Uncategorized
  - Nixpkgs (upstream)
    - Metrics
      - Maintaining ${nixos.derivations} derivations, ${nixos.update-scripts} of which have an explicit update script
    - Migrated derivations, services and tests from monorepo
''
