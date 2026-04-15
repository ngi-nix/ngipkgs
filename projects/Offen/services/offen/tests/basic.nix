{
  sources,
  ...
}:

{
  name = "Offen";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.offen
          sources.examples.Offen."Enable Offen server"
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
