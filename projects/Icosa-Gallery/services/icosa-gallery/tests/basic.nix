{
  sources,
  ...
}:

{
  name = "Icosa Gallery";

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
      port = toString nodes.machine.services.icosa-gallery.port;
    in
    ''
      start_all()

      machine.wait_for_unit("icosa-gallery.service")
      machine.wait_for_open_port(${port})

      machine.succeed("curl -v http://localhost:${port} >&2")
    '';

  interactive.sshBackdoor.enable = true;
  interactive.nodes = {
    machine =
      { config, ... }:
      {
        services.icosa-gallery.host = "0.0.0.0";

        # forward ports from VM to host
        virtualisation.forwardPorts =
          let
            inherit (config.services.icosa-gallery) port;
          in
          [
            {
              from = "host";
              host = { inherit port; };
              guest = { inherit port; };
            }
          ];

        # forwarded ports need to be accessible
        networking.firewall.enable = false;
      };
  };
}
