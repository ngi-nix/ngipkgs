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
      machine.succeed("su cnsprcy -c 'cnspr --help'")
      machine.succeed("su cnsprcy -c 'cnspr status'")
    '';
}
