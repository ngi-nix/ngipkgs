{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./module.nix ];

  # No extra configuration needed for the demo; formulas is a CLI tool.
  system.stateVersion = "26.05";
}
