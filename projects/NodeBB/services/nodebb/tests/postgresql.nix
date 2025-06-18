{
  sources,
  ...
}:

{
  name = "NodeBB";

  interactive.sshBackdoor.enable = true;

  nodes.machine = {
    imports = [
      sources.modules.ngipkgs
      sources.modules.services.nodebb
      sources.examples.NodeBB.postgresql
    ];
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("nodebb.service")
      machine.wait_for_open_port(${builtins.toString nodes.machine.services.nodebb.settings.port})

      machine.succeed("curl -v ${nodes.machine.services.nodebb.settings.url} >&2")
    '';
}
