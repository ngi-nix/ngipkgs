{
  sources,
  ...
}:

{
  name = "Manyfold";

  nodes.machine = {
    virtualisation.memorySize = 4096;

    imports = [
      sources.modules.ngipkgs
      sources.modules.services.manyfold
      sources.examples.Manyfold."Enable Manyfold with PostgreSQL"
    ];
  };

  testScript =
    { nodes, ... }:
    let
      port = toString nodes.machine.services.manyfold.port;
    in
    ''
      start_all()

      machine.wait_for_unit("default.target")
      machine.wait_for_unit("manyfold.service")
      machine.wait_for_open_port(${port})
      machine.succeed("curl http://localhost:${port}")
    '';
}
