{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.ethersync;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      ethersync = cfg.package;
      neovim = config.programs.neovim.finalPackage;
      vscode = config.programs.vscode.finalPackage;
    };
  };
}
