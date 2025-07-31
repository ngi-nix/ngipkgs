{
  sources,
  ...
}:

{
  name = "peertube-runner";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.peertube-runner
          sources.examples.PeerTube.basic-runner
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("peertube-runner.service")
      machine.succeed("sudo -u prunner peertube-runner --version")
    '';
}
