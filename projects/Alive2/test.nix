{
  sources,
  ...
}:
{
  name = "Alive2";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.alive2
          sources.examples.Alive2.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("alive --help")
    '';
}
