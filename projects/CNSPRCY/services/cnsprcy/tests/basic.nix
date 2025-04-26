{
  sources,
  ...
}:

{
  name = "cnsprcy-server";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.cnsprcy
          sources.examples.CNSPRCY.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("cnsprcy.service")
      machine.succeed("cnspr --help")
      machine.succeed("cnspr status")
    '';
}
