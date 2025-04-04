{
  sources,
  ...
}:
{
  name = "galene";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.galene
          sources.examples.Galene.galene
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()
    '';
}
