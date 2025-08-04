{
  sources,
  ...
}:
{
  name = "cryptpad-demo";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.cryptpad
          sources.examples.Cryptpad."Enable Cryptpad"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      servicePort = toString nodes.machine.services.cryptpad.settings.httpPort;
    in
    ''
      start_all()

      machine.wait_for_unit("cryptpad.service")
      machine.wait_for_open_port(${servicePort})

      machine.succeed("curl --fail http://localhost:${servicePort}")
    '';
}
