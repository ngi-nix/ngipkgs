{
  lib,
  pkgs,
  sources,
  system,
  ...
}:
# TODO: document formatter and pre-commit hook
lib.makeExtensible (self: {
  treefmt = import sources.treefmt-nix;
  pre-commit-hooks = sources.pre-commit-hooks.lib.${system};

  config = {
    projectRootFile = "flake.nix";

    programs.actionlint.enable = true;
    programs.nixfmt.enable = true;
    programs.zizmor.enable = false;

    settings.formatter.editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      priority = 9; # last
    };
  };

  # could be useful for debugging
  eval = self.treefmt.evalModule pkgs self.config;

  # treefmt package
  package = self.treefmt.mkWrapper pkgs self.config;

  # development shell that contains all formatters
  shell = self.eval.config.build.devShell;

  hooks.pre-commit = self.pre-commit-hooks.run {
    src = ../.;
    hooks.treefmt.package = self.package;
  };
})
