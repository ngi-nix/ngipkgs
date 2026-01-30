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
          sources.examples.CNSPRCY."Enable CNSPRCY program"
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
