{
  sources,
  ...
}:

{
  name = "Serivce Name";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.zwm-server
          sources.examples."0WM"."Enable 0WM server"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    # py
    ''
      start_all()

      machine.wait_for_unit("zwm-server.service")
    '';
}
