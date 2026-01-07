{
  lib,
  sources,
  ...
}:
{
  name = "misskey";

  nodes.machine = {
    imports = [
      sources.modules.ngipkgs
      sources.modules.services.misskey
      sources.examples.Misskey.basic
    ];
  };

  testScript =
    { nodes, ... }:
    let
      port = nodes.machine.services.misskey.settings.port;
    in
    # python
    ''
      machine.wait_for_unit("misskey.service")
      machine.wait_for_open_port(${toString port})
      machine.succeed("curl --fail http://localhost:${toString port}/")
    '';
}
