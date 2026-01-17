{
  lib,
  ...
}@args:
let
  inherit (lib.types)
    submodule
    ;
in
{
  binary = submodule ./binary.nix;
  demo = submodule ./demo.nix;
  example = submodule ./example.nix;
  link = submodule ./link.nix;
  metadata = submodule ./metadata.nix;
  problem = import ./problem.nix args;
  program = submodule (import ./module.nix { type = "program"; });
  plugin = submodule ./plugin.nix;
  project = submodule ./project.nix;
  service = submodule (import ./module.nix { type = "service"; });
  subgrant = submodule ./subgrant.nix;
  test = submodule ./test.nix;
}
