{
  sources,
  ...
}:

{
  name = "peertube-cli";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.peertube-cli
          sources.examples.PeerTube.basic-cli
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("peertube-cli --version")
    '';
}
