{
  sources,
  ...
}:

{
  name = "holo";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.holo
          sources.examples.holo."Enable the holo program"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("holo-cli --version")
    '';
}
