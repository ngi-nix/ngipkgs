/**
    NixOS module, either for a program that runs in the shell, or a service that runs in the background.

    :::{.example}

    ```nix
    { ... }@args:
    {
      nixos.modules.programs.PROGRAM_NAME = {
        module = ./programs/PROGRAM_NAME/module.nix;
        examples."Enable PROGRAM_NAME" = {
          module = ./programs/PROGRAM_NAME/examples/basic.nix;
          description = "Basic configuration example for PROGRAM_NAME";
          tests.basic.module = ./programs/PROGRAM_NAME/tests/basic.nix;
        };
      };
    }
    ```

    :::

    :::{.example}

    ```nix
    { ... }@args:
    {
      nixos.modules.services.SERVICE_NAME = {
        module = ./services/SERVICE_NAME/module.nix;
        examples."Enable SERVICE_NAME" = {
          module = ./services/SERVICE_NAME/examples/basic.nix;
          description = "Basic configuration example for SERVICE_NAME";
          tests.basic.module = ./services/SERVICE_NAME/tests/basic.nix;
        };
      };
    }
    ```

    :::

    For modules that reside in NixOS, use:

    ```nix
    { lib, ... }:
    {
      nixos.modules.programs.PROGRAM_NAME.module = lib.moduleLocFromOptionString "programs.PROGRAM_NAME";
    }
    ```

    If you want to extend such modules, you can import them in a new module:

    ```nix
    {
      nixos.modules.programs.PROGRAM_NAME.module = ./module.nix;
    }
    ```

    Where `module.nix` contains:

    ```nix
    { lib, ... }:
    {
      imports = [
        (lib.moduleLocFromOptionString "programs.PROGRAM_NAME")
      ];

      options.programs.PROGRAM_NAME = {
        extraOption = lib.mkEnableOption "extra option";
      };
    }
    ```

    The same applies to services as well for the examples, above.

    > [!TIP]
    > You can use the [NixOS Search](https://search.nixos.org/options?channel=unstable) to check if modules exist upstream.

    > [!NOTE]
    > - Each module must include at least one example, so users get an idea of what to do with it (see [example](#libexample)).
    > - Examples must be tested (see [test](#libtest)).

    After implementing the module, run the [checks](#checks) to make sure that everything is correct.
*/
# TODO: modular services

{
  type,
}:

assert builtins.elem type [
  "program"
  "service"
];

{
  lib,
  name,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  ngiTypes = import ./. { inherit lib; };

  inherit (ngiTypes)
    example
    link
    plugin
    ;
in

{
  options = {
    name = mkOption {
      type = with types; str;
      default = name;
      description = "Name of the ${type}";
    };
    module = mkOption {
      type = with types; nullOr path;
      description = ''
        Contains the path to the NixOS module for the ${type}.
      '';
    };
    examples = mkOption {
      type = with types; attrsOf example;
      description = ''
        Configurations that illustrate how to set up the ${type}.

        > [!NOTE]
        > ${type} must include at least one example, so users get an idea of what to do with it.
      '';
      example = lib.literalExpression ''
        nixos.modules.${type}s.examples."Enable foobar" = {
          module = ./${type}s/foobar/examples/basic.nix;
          description = "Basic configuration example for foobar";
          tests.foobar-basic.module = import ./${type}s/foobar/tests/basic.nix args;
        };
      '';
      default = { };
    };
    links = mkOption {
      type = with types; attrsOf link;
      description = ''
        Links to documentation or resources that may help building, configuring and testing the ${type}.
      '';
      example = {
        usage = {
          text = "Usage examples";
          url = "https://docs.foobar.com/quickstart";
        };
        build = {
          text = "Build from source";
          url = "https://docs.foobar.com/dev";
        };
      };
      default = { };
    };
    extensions = mkOption {
      type = with types; attrsOf (nullOr plugin);
      default = { };
      description = "Component extensions for the ${type}";
    };
  };
}
