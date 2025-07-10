{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ethersync;
in
{
  options.programs.ethersync = {
    enable = lib.mkEnableOption "Ethersync";
    package = lib.mkPackageOption pkgs "ethersync" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    demo-shell.ethersync.programs = {
      ethersync = cfg.package;
      neovim = config.programs.neovim.finalPackage;
    };
  };
}
