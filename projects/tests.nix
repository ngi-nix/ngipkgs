{
  lib,
  pkgs,
  sources,
  project,
  examples,
  ...
}:
let
  nixosTest =
    test:
    let
      # Amenities for interactive tests
      tools =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            vim
            tmux
            jq
          ];
          # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
          # to provide a slightly nicer console.
          # kmscon allows zooming with [Ctrl] + [+] and [Ctrl] + [-]
          services.kmscon = {
            enable = true;
            autologinUser = "root";
            fonts = [
              {
                name = "Hack";
                package = pkgs.hack-font;
              }
            ];
          };
        };
      debugging.interactive.nodes = lib.mapAttrs (_: _: tools) test.nodes;
      args = {
        imports = [
          debugging
          test
        ];
        # we need to extend pkgs with ngipkgs, so it can't be read-only
        node.pkgsReadOnly = false;
      };
    in
    if lib.isDerivation test then test else pkgs.testers.runNixOSTest args;

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
lib.mapAttrs (
  _: test:
  if lib.isString test.module || lib.isPath test.module then
    nixosTest (
      import test.module {
        inherit pkgs lib sources;
        inherit (pkgs) system;
      }
    )
  else
    nixosTest test.module
) filtered-tests
