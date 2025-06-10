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
          sources.examples.xrsh.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("xrsh >&2 &")

      # xrsh serves defaultly on :8080
      machine.wait_for_open_port(8090)
      machine.succeed("curl -i 0.0.0.0:8090")
    '';
}
