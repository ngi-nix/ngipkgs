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
          sources.modules.services.cnsprcy
          sources.examples.CNSPRCY.basic
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
