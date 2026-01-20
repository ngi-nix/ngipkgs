/**
  Configuration of an application module that illustrates how to use it.

  :::{.example}

  ```nix
  { ... }@args:
  {
    nixos.modules.services.SERVICE_NAME.examples = {
      "Basic mail server setup with default ports" = {
        module = ./services/SERVICE_NAME/examples/basic.nix;
        description = "Send email via SMTP to port 587 to check that it works";
        tests.basic.module = ./services/SERVICE_NAME/tests/basic.nix;
      };
    };
  }
  ```

  :::

  # Options

  - `module`

    File path to a NixOS module that contains the application configuration

  - `description`

    Description of the example, ideally with further instructions on how to use it

  - `tests`

    At least one test for the example (see [test](#libtest))

  - `links`

    Links to related resources (see [link](#liblink))
*/
{
  lib,
  name,
  ngiTypes,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  inherit (ngiTypes)
    test
    link
    ;
in

{
  options = {
    name = mkOption {
      type = with types; str;
      default = name;
      description = "short description of the example";
      example = {
        name = "Basic mail server setup with default ports";
      };
    };
    module = mkOption {
      description = ''
        File path to a NixOS module that contains the application configuration
      '';
      type = with types; nullOr path;
    };
    description = mkOption {
      description = "detailed description of the example, ideally with further instructions on how to use it";
      type = with types; nullOr str;
      default = null;
    };
    tests = mkOption {
      description = "at least one test for the example";
      type = with types; attrsOf test;
      default = { };
    };
    links = mkOption {
      description = "links to related resources";
      type = with types; attrsOf link;
      default = { };
    };
  };
}
