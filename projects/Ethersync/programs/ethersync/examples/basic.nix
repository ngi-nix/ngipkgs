{ pkgs, ... }:

{
  programs.ethersync.enable = true;

  programs.vscode = {
    # vscodium because vscode is unfree
    package = pkgs.vscodium;
    extensions = [
      pkgs.vscode-extensions.ethersync.ethersync
    ];
  };

  programs.neovim = {
    enable = true;
    configure = {
      packages.ethersync = {
        start = [
          pkgs.nvim-ethersync
        ];
      };
    };
  };
}
