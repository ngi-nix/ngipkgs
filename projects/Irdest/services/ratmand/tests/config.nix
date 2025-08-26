{
  sources,
  ...
}:

{
  name = "ratmand-config";

  nodes = {
    machine = {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.ratmand
        sources.examples.Irdest.basic-ratmand
      ];

      # Make sure that there are no errors when generatig a config
      # file using all of the available types.
      services.ratmand.settings = {
        ratmand = {
          accept_unknown_peers = true; # bool
          api_bind = "localhost:5853"; # str
          peers = [ "inet:hub.irde.st:5860" ]; # peers
        };
        lan.port = 5862; # int
      };

      # ratmand fails to allocate all of its memory with only 1024
      virtualisation.memorySize = 1536;
    };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("ratmand.service")
    '';
}
