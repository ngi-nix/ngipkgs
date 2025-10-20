{
  sources,
  ...
}:

{
  name = "irdest-demo-basic";

  nodes = {
    machine = {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.ratmand
        sources.examples.Irdest.basic-ratmand
      ];

      # ratmand fails to allcate all of its memory with only 1024
      virtualisation.memorySize = 1536;

      services.ratmand.settings = {
        ratmand = {
          accept_unknown_peers = true;
          # TODO: This is not required for the server, but the test breaks if
          # this is not specified because of issues with the config file.
          # Investigate further.
          peers = [ "" ];
        };
      };
    };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("ratmand.service")
      machine.wait_for_console_text("Listening to API socket")
      machine.succeed("ratctl status system")
    '';
}
