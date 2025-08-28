{
  sources,
  ...
}:

{
  name = "Icosa Gallery";

  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.icosa-gallery
          sources.examples.Icosa-Gallery."Enable icosa-gallery"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      inherit (nodes.machine.services.icosa-gallery) port;
    in
    ''
      start_all()

      machine.wait_for_unit("icosa-gallery.service")
      machine.wait_for_open_port(${port})

      machine.succeed("curl -v http://localhost:${port} >&2")
    '';
}
