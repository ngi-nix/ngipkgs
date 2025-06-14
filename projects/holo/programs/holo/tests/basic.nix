{
  sources,
  ...
}:

{
  name = "Program Name";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.holo
          sources.examples.holo.basic
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
