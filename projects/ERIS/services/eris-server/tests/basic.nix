{
  sources,
  ...
}:

{
  name = "eris-server-basic";

  nodes = {
    server =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.eris-go
          sources.examples.ERIS.basic
        ];
      };
  };

  testScript =
    { ... }:
    ''
      start_all()
      server.wait_for_unit("multi-user.target")
      server.wait_for_open_port(5683)
      server.wait_for_open_port(80)
      server.succeed("curl -i \"http://[::1]/uri-res/N2R?$(echo 'Hail ERIS!' | eris-go put -store coap+tcp://[::1]:5683)\"")
    '';
}
