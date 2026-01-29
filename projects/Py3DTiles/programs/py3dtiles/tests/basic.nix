{
  sources,
  ...
}:

{
  name = "py3dtiles";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.py3dtiles
          sources.examples.Py3DTiles.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("multi-user.target")

      print(machine.succeed("py3dtiles --help"))
    '';
}
