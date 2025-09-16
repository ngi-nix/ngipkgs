{
  sources,
  ...
}:
{
  name = "xrsh";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.xrsh
          sources.examples.xrsh."Enable xrsh and set a port to serve on"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      XRSH_PORT = toString nodes.machine.programs.xrsh.port;
    in
    ''
      start_all()

      machine.succeed("xrsh >&2 &")

      # xrsh serves defaultly on :8080
      machine.wait_for_open_port(${XRSH_PORT})
      machine.succeed("curl -i 0.0.0.0:${XRSH_PORT}")
    '';
}
