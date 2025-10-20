{
  sources,
  ...
}:
{
  name = "funkwhale-demo-basic";

  nodes = {
    machine = {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.funkwhale
        sources.examples.Funkwhale."Basic local configuration"
        ../module-demo.nix
      ];
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("funkwhale.target")

    # Website is served on the demo port.
    machine.succeed("curl --fail http://localhost:12345")
  '';
}
