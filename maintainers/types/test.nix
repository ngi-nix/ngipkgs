/**
  NixOS test that ensures that project components behave as intended.

  # Adding a NixOS test

  You can write a module as outlined in the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-writing-nixos-tests), then import it with the appropriate arguments:

  ```nix
  { ... }@args:
  {
    tests.basic.module = ./test.nix;
  }
  ```

  You can also re-use tests from NixOS:

  ```nix
  { pkgs, ... }@args:
  {
    tests.basic.module = pkgs.nixosTests.TEST_NAME;
  }
  ```

  # Marking tests as broken

  Tests with issues need to be labeled as broken, with a clear description of the problem and links to additional information.

  :::{.example}

  ```nix
  problem.broken.reason = ''
    The derivation fails to build on python 3.13 due to failing tests.

    For more details, see: https://github.com/pallets-eco/flask-alembic/issues/47
  '';
  ```

  :::
*/
{
  lib,
  pkgs,
  sources,
  config,
  ngiTypes,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  inherit (ngiTypes)
    problem
    ;

  # TODO: move into `lib.nix`?
  nixosTest =
    test:
    let
      # Amenities for interactive tests
      tools = {
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
    if lib.isDerivation test then
      lib.lazyDerivation { derivation = test; }
    else if test == null || config.problem != null then
      null
    else if test ? meta.broken && test.meta.broken then
      null
    else
      lib.lazyDerivation { derivation = pkgs.testers.runNixOSTest args; };

  callTest =
    module:
    if lib.isString module || lib.isPath module then
      nixosTest (
        import module {
          inherit pkgs lib sources;
          inherit (pkgs) system;
        }
      )
    else if module == null || config.problem != null then
      null
    else
      nixosTest module;
in

{
  options = {
    module = mkOption {
      # NOTE:
      # Tests are composed to derivations, but we don't want to
      # evaluate them as such because that slows down the overview build
      # considerably.
      #
      # This is because test nodes are eagerly evaluated to create the
      # driver's `vmStartScripts` (see `nixos/lib/testing/driver.nix` in
      # NixOS).
      type =
        with types;
        nullOr (coercedTo (either deferredModule package) callTest (nullOr deferredModule));
      default = null;
      description = "NixOS test module";
    };
    problem = mkOption {
      type = with types; nullOr problem;
      default = null;
      description = "Any known problems or issues with the test";
    };
  };
}
