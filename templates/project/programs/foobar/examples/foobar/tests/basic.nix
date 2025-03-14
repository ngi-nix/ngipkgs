{
  sources,
  ...
}:

{
  name = "foobar";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.foobar
          sources.examples.Foobar.foobar
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("foobar --help")
    '';
}
