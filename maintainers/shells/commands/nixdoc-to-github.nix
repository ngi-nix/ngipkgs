# nix-shell --run nixdoc-to-github
{ nixdoc-to-github }:
let
  cmd = nixdoc-to-github.lib.nixdoc-to-github.run {
    description = "NGI Project Types";
    category = "";
    file = "${toString ../../../projects/types.nix}";
    output = "${toString ../../../maintainers/docs/project.md}";
  };
in
cmd.overrideAttrs {
  meta.description = "convert nixdoc output to GitHub markdown";
}
