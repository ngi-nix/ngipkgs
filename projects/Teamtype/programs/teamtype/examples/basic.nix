{ pkgs, ... }:

{
  programs.teamtype.enable = true;

  programs.vscode = {
    enable = true;
    # vscodium because vscode is unfree
    package = pkgs.vscodium;
    extensions = [
      pkgs.vscode-extensions.teamtype.teamtype
    ];
  };

  programs.neovim = {
    enable = true;
    configure = {
      packages.teamtype = {
        start = [
          pkgs.vimPlugins.teamtype
        ];
      };
    };
  };
}
