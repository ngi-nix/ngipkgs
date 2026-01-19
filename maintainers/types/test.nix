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
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  ngiTypes = import ./. { inherit lib; };

  inherit (ngiTypes)
    problem
    ;
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
      type = with types; nullOr (either deferredModule package);
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
