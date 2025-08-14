{
  sources,
  ...
}:

{
  name = "Kazarma";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.kazarma
          sources.examples.Kazarma."Enable kazarma"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("kazarma.service")
    '';
}
