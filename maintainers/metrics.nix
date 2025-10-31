# Provide useful metrics about NGIpkgs deliverables

## USAGE

# nix eval --json -f default.nix metrics.summary

# Latest Nixpkgs:
#
# nix eval --json -f default.nix metrics.summary --override-input nixpkgs "github:NixOS/nixpkgs"

{
  lib,
  pkgs,
  ngipkgs,
  raw-projects,
}:
let
  inherit (lib)
    attrNames
    concatMap
    attrValues
    filterAttrs
    mapAttrs
    elem
    optionalAttrs
    filter
    length
    ;

  # return number of elements for a project's component
  countComponent =
    project: component:
    if project.${component} == null then 0 else length (attrNames project.${component});

  project-metrics = mapAttrs (
    _: p:
    optionalAttrs (p ? nixos) {
      metadata = {
        subgrants =
          if lib.isAttrs p.metadata.subgrants then
            mapAttrs (_: length) p.metadata.subgrants
          else
            { Uncategorized = length p.metadata.subgrants; };
      };
      nixos = {
        tests = countComponent p.nixos "tests";
        examples = countComponent p.nixos "examples";
      }
      // optionalAttrs (p ? nixos.modules.services) {
        services = countComponent p.nixos.modules "services";
      }
      // optionalAttrs (p ? nixos.modules.programs) {
        programs = countComponent p.nixos.modules "programs";
      }
      // optionalAttrs (p ? nixos.demo) {
        demos = countComponent p.nixos "demo";
      };
    }
  ) raw-projects;

  /**
    Sum all metrics of an attribute set

    # Inputs

    `attrPath`

    : String that contains the attribute path

    # Type

    ```
    countAttrs :: String -> AttrSet
    ```
  */
  countAttrs =
    attrPath:
    lib.foldlAttrs (
      acc: name: value:
      let
        component = lib.attrByPath (lib.splitString "." attrPath) { } value;
        names = attrNames component;
        accumulate = attr: (acc.${attr} or 0) + (component.${attr} or 0);
      in
      lib.foldl (acc: name: acc // { "${name}" = accumulate name; }) acc names
    ) { } project-metrics;

  nixos-derivations =
    let
      maintained = import ./metrics-maintainer.nix { inherit pkgs; };
      packages = pkgs.writeText "packages" (lib.strings.toJSON maintained.packages);
    in
    pkgs.runCommandNoCC "nixos-derivations"
      {
        nativeBuildInputs = with pkgs; [ jq ];
      }
      ''
        mkdir -p $out

        cat ${packages} \
          | jq '[.. | objects | select(has("name")) | .name]' \
          > $out/packages.json

        cat ${packages} \
          | jq '[.. | objects | select(has("update-script") and .["update-script"] == true) | .name]' \
          > $out/packages-update-script.json

        jq -n \
          --arg derivations $(jq length $out/packages.json) \
          --arg update-script $(jq length $out/packages-update-script.json) \
          '$ARGS.named' \
          > "$out/count.json"
      '';

  summary = {
    ngipkgs = {
      projects = length (attrNames raw-projects);
      derivations = length (attrNames ngipkgs);
      metadata = {
        subgrants = countAttrs "metadata.subgrants";
      };
      update-scripts = length (filter (d: d ? passthru.updateScript) (attrValues ngipkgs));
    };
    nixos = (countAttrs "nixos") // {
      derivations = length (lib.importJSON "${nixos-derivations}/packages.json");
      update-script = length (lib.importJSON "${nixos-derivations}/packages-update-script.json");
    };
  };
in
rec {
  inherit
    project-metrics
    summary
    nixos-derivations
    ;

  metrics = {
    projects = attrNames raw-projects;
    derivations = attrNames ngipkgs;
    with-services = attrNames (
      filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects
    );
    missing-services = attrNames (
      filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services == null) raw-projects
    );
    services = concatMap attrNames (
      concatMap (p: attrValues p.nixos.modules) (
        attrValues (
          filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects
        )
      )
    );
    with-tests = attrNames (
      filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects
    );
    missing-tests = attrNames (
      filterAttrs (name: p: p ? nixos.tests && p.nixos.tests == null) raw-projects
    );
    tests = concatMap (p: attrNames p.nixos.tests) (
      attrValues (filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects)
    );
    with-examples = attrNames (
      filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects
    );
    missing-examples = attrNames (
      filterAttrs (name: p: p ? nixos.examples && p.nixos.examples == null) raw-projects
    );
    examples = concatMap (p: attrNames p.nixos.examples) (
      attrValues (filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects)
    );
    update-scripts = filter (d: d ? passthru.updateScript) (attrValues ngipkgs);
    nixpkgs-update-scripts = filter (
      d:
      (builtins.tryEval d).success
      && (elem lib.teams.ngi d.meta.teams or [ ])
      && d ? passthru.updateScript
    ) (attrValues pkgs);
    demo = filter (p: p.nixos.demo != null) (attrValues raw-projects);
  };

  count = mapAttrs (name: length) metrics;
}
