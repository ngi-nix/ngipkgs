{
  ethersync,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "nvim-ethersync";

  inherit (ethersync) meta src version;

  sourceRoot = "${src.name}/vim-plugin";
}
