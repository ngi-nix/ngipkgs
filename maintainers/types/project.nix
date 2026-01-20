/**
    NGI-funded software application.

    ```
    project
    ├── metadata
    │   ├── summary
    │   ├── subgrants
    │   └── links
    ├── binary
    └── nixos
        ├── demo
        │   └── tests
        ├── programs
        │   └── examples
        │       └── tests
        └── services
            └── examples
                └── tests
    ```

    # Checks

    After implementing one of a project's components:

    1. Verify that its checks are successful:

      ```shellSession
      nix-build -A checks.PROJECT_NAME
      ```

    1. Run the tests, if they exist, and make sure they pass:

      ```shellSession
      nix-build -A projects.PROJECT_NAME.nixos.tests.TEST_NAME
      ```

    1. [Run the overview locally](https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md#running-and-testing-the-overview-locally), navigate to the project page and make sure that the options and examples shows up correctly

    1. [Make a Pull Request on GitHub](https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md#how-to-contribute-to-ngipkgs)
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
    metadata
    binary
    program
    service
    demo
    example
    test
    ;
in
{
  options = {
    name = mkOption {
      type = types.str;
      default = name;
      description = "Project name";
    };

    metadata = mkOption {
      type = with types; nullOr metadata;
      default = null;
      description = "Metadata about the project";
    };

    binary = mkOption {
      type = with types; attrsOf binary;
      default = { };
      description = "Binary assets and firmware associated with the project";
    };

    nixos = mkOption {
      type =
        with types;
        submodule {
          options = {
            modules = {
              programs = mkOption {
                type = attrsOf program;
                description = "Software that can be run in the shell";
                example = lib.literalExpression ''
                  nixos.modules.programs.foobar = {
                    module = ./programs/foobar/module.nix;
                    examples.basic = {
                      module = ./programs/foobar/examples/basic.nix;
                      description = "Basic configuration example for foobar";
                      tests.basic.module = import ./programs/foobar/tests/basic.nix args;
                    };
                  };
                '';
                default = { };
              };
              services = mkOption {
                type = attrsOf service;
                description = "Software that runs as a background process";
                default = { };
              };
            };
            demo = mkOption {
              type = nullOr (attrTag {
                vm = mkOption {
                  type = demo;
                  description = "Virtual Machine";
                };
                shell = mkOption {
                  type = demo;
                  description = "Terminal shell";
                };
              });
              default = null;
              description = "Environment for running the application demonstration";
            };
            /**
              Configuration of an existing application module that illustrates how to use it.

              An application component may have examples using it in isolation,
              but examples may involve multiple application components.
              Having examples at both layers allows us to trace coverage more easily.
              If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
              we can still reduce granularity and move all examples to the application level.
            */
            examples = mkOption {
              type = attrsOf example;
              description = "A configuration of an existing application module that illustrates how to use it";
              default = { };
            };
            # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
            #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
            #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
            #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
            tests = mkOption {
              type = attrsOf test;
              default = { };
              description = "NixOS test that ensures project components behave as intended";
            };
          };
        };
      description = "NixOS-related components";
    };
  };
}
