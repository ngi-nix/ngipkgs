{
  pkgs,
  sources,
  system,
  ...
}:
let
  git-hooks = import sources.git-hooks { inherit system; };
  treefmt-nix = import sources.treefmt-nix;
in
rec {
  treefmt = treefmt-nix.mkWrapper pkgs {
    projectRootFile = "default.nix";
    programs.nixfmt.enable = true;
    programs.actionlint.enable = true;
  };

  pre-commit-hook = pkgs.writeShellScriptBin "git-hooks" ''
    if [[ -d .git ]]; then
      ${with git-hooks.lib.git-hooks; pre-commit (wrap.abort-on-change treefmt)}
    fi
  '';

  format = pkgs.writeShellScriptBin "format" ''
    ${treefmt}/bin/treefmt
  '';
}
