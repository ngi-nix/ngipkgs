{
  sources,
  ...
}:

{
  name = "jaq";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.jaq
          sources.examples.jaq.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("jaq --version")
    '';
}
