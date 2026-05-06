{
  lib,
  pkgs,
  sources,
  project,
  examples,
  ...
}:
let
  # TODO: refactor
  tests = lib.mergeAttrsList [
    (project.nixos.tests or { })
    (project.nixos.demo.vm.tests or { })
    (project.nixos.demo.shell.tests or { })
    (lib.filter-map examples "tests")
  ];

  filtered-tests = lib.filterAttrs (
    _: test: (!test ? problem.broken) && (test ? module && test.module != null)
  ) tests;
in
filtered-tests
