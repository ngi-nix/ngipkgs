{
  sources,
  ...
}:

{
  name = "Mox";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.mox
          sources.examples.mox.basic # i.e _ProjectName_.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed()
    '';
}
