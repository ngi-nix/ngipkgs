/**
  Practical demonstration of an application.

  It provides an easy way for users to test its functionality and assess its suitability for their use cases.

  :::{.example}

  ```nix
  nixos.demo.TYPE = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Run `foobar` in the terminal
        '';
      }
      {
        instruction = ''
          Visit [http://127.0.0.1:8080](http://127.0.0.1:8080) in your browser
        '';
      }
    ];
    tests = {
      # See the section for contributing tests
    };
  };
  ```

  :::

  - Replace `TYPE` with either `vm` or `shell`.
  This indicates the preferred environment for running the application: NixOS VM or terminal shell.

  - In a demo VM, to forward ports from guest to host, you need to open them in the firewall:

  ```nix
  networking.firewall.allowedTCPPorts = [ 8080 ];
  ```

  - Use `module` for the application configuration and `module-demo` for demo-specific things, like [demo-shell](https://github.com/ngi-nix/ngipkgs/blob/main/overview/demo/shell.nix).
  For the latter, it could be something like:

  :::{.example}

  ```nix
  # ./demo/module-demo.nix
  {
    lib,
    config,
    ...
  }:
  let
    cfg = config.programs.foobar;
  in
  {
    config = lib.mkIf cfg.enable {
      demo-shell = {
        programs.foobar = cfg.package;
        env.TEST_PORT = toString cfg.port;
      };
    };
  }
  ```

  :::

  > [!TIP]
  > [Example](#libexample) modules can also be used for demos, if they clearly describe how the application should be configured and used.

  After implementing the demo, run the following commands to test it:

  - With classic Nix:

    ```shellSession
    nix-build -A demos.PROJECT_NAME
    ```

  - With flakes:

    ```shellSession
    nix run .#demos.PROJECT_NAME
    ```

  Then, run the [checks](#checks) to make sure that everything is correct.
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
    example
    problem
    ;

  instruction = types.submodule {
    options.instruction = mkOption {
      type = with types; str;
      description = ''
        Markdown text that describes a single step
      '';
    };
  };
in

{
  options = {
    inherit (example.getSubOptions { })
      module
      tests
      description
      links
      ;
    module-demo = mkOption {
      description = ''
        NixOS module that contains everything needed to use an application demo conveniently
      '';
      type = types.deferredModuleWith {
        staticModules =
          lib.optionals (name == "vm") [
            ../../overview/demo/vm
          ]
          ++ lib.optionals (name == "shell") [
            ../../overview/demo/shell.nix
          ];
      };
      default = { };
    };
    type = mkOption {
      type = types.enum [
        "vm"
        "shell"
      ];
      default = name;
      description = "Type of demo environment";
    };
    problem = mkOption {
      type = with types; nullOr problem;
      default = null;
      description = "Any known problems or issues with the demo";
      example = {
        problem.broken = {
          reason = "Does not work as intended. Needs fixing.";
        };
      };
    };
    usage-instructions = mkOption {
      type = with types; nullOr (listOf instruction);
      description = ''
        Steps that users should follow to use the demo
      '';
      default = [ ];
    };
  };
}
