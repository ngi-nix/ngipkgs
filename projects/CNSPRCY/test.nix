{
  sources,
  ...
}:
{
  name = "cnsprcy";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.cnsprcy
          sources.examples.CNSPRCY.cnsprcy
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("cnspr --help")
    '';
}
