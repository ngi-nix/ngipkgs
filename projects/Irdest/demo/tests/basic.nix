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

      # ratmand fails to alocate all of its memory with only 1024
      virtualisation.memorySize = 1536;
    };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("ratmand.service")
      # API isn't available immediately after the service is ready.
      machine.succeed("sleep 3")

      machine.succeed("ratctl status system")
    '';
}
