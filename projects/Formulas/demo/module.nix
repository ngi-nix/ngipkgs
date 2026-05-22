{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/formulas/module.nix
  ];

  programs.formulas.enable = true;
}
