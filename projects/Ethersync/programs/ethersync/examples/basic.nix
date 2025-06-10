{ pkgs, ... }:

{
  programs.ethersync.enable = true;

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
