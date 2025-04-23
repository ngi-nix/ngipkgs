{
  lib,
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
    count
    optionalAttrs
    ;
in
rec {
  metrics = {
    projects = attrNames raw-projects;
    in-ngipkgs = attrNames ngipkgs;
    derivations = concatMap (p: attrNames p.packages) (attrValues raw-projects);
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
  };

  metrics-count = mapAttrs (name: value: count (_: true) value) metrics;

  project-metrics = mapAttrs (
    _: p:
    {
      derivations = count (_: true) (attrNames p.packages);
    }
    // optionalAttrs (p ? nixos) {
      nixos =
        {
          tests = if p.nixos.tests == null then 0 else count (_: true) (attrNames p.nixos.tests);
          examples = if p.nixos.examples == null then 0 else count (_: true) (attrNames p.nixos.examples);
        }
        // optionalAttrs (p ? nixos.modules.services) {
          services =
            if p.nixos.modules.services == null then
              0
            else
              count (_: true) (attrNames p.nixos.modules.services);
        }
        // optionalAttrs (p ? nixos.modules.programs) {
          programs =
            if p.nixos.modules.programs == null then
              0
            else
              count (_: true) (attrNames p.nixos.modules.programs);
        };
    }
  ) raw-projects;
}
