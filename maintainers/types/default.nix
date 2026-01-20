{
  lib,
  ...
}@args:
let
  inherit (lib)
    types
    mkOption
    ;

  submodule =
    modules:
    types.submodule {
      imports = [
        {
          config._module.args = args // {
            ngiTypes = options.ngiTypes.default;
          };
        }
      ]
      ++ lib.toList modules;
    };

  options.ngiTypes = mkOption {
    type = with types; attrs;
    default = {
      binary = submodule ./binary.nix;
      demo = submodule ./demo.nix;
      example = submodule ./example.nix;
      link = submodule ./link.nix;
      metadata = submodule ./metadata.nix;
      problem = import ./problem.nix args;
      program = submodule (import ./module.nix { type = "program"; });
      plugin = submodule ./plugin.nix;
      project = submodule ./project.nix;
      projects = mkOption {
        type = with types; attrsOf (submodule ./project.nix);
        description = "NGI-funded software application";
      };
      service = submodule (import ./module.nix { type = "service"; });
      subgrant = submodule ./subgrant.nix;
      test = submodule ./test.nix;
    };
    description = "NixOS module-system data types for NGI-funded software";
  };
in
{
  inherit options;
}
