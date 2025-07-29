{
  sources,
  pkgs,
  lib,
  ...
}:

{
  name = "owasp blint test";

  meta.maintainers = with lib; [
    maintainers.ethancedwards8
    teams.ngi
  ];

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.owasp
          sources.examples.owasp."Enable owasp"
        ];

        environment.systemPackages = with pkgs; [
          jq
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed('blint -i ${lib.getExe pkgs.ripgrep} -o /tmp/ripgrep')
      machine.succeed('jq . /tmp/ripgrep/*.json')
    '';
}
