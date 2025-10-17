{
  sources,
  ...
}:

{
  name = "0WM server";

  nodes = {
    machine =
      { lib, config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.zwm-server
          sources.modules.programs.zwm-client
          sources.examples."0WM"."Enable 0WM server"
          sources.examples."0WM"."Enable 0WM client"
        ];

        services.zwm-server.settings.port = lib.mkForce 8000;

        virtualisation.forwardPorts =
          let
            cfg = config.services.zwm-server;
          in
          [
            {
              from = "host";
              host.port = cfg.settings.port;
              guest.port = cfg.settings.port;
            }
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
