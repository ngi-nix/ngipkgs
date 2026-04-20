{
  sources,
  ...
}:
{
  name = "Arcan";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.arcan
          sources.examples.Arcan.base
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("arcan --help")
    '';
}
