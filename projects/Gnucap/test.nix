{
  sources,
  ...
}:
{
  name = "gnucap";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.gnucap
          sources.examples.Gnucap.gnucap
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.succeed('echo | gnucap | grep "Gnucap : The Gnu Circuit Analysis Package"')
    '';
}
