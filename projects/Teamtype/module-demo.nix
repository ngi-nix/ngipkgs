{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.teamtype;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      teamtype = cfg.package;
      neovim = config.programs.neovim.finalPackage;
      vscode = config.programs.vscode.finalPackage;
    };
  };
}
