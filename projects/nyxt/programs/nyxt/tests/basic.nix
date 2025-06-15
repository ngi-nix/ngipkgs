{
  sources,
  ...
}:

{
  name = "nyxt";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.nyxt
          sources.examples.nyxt.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("nyxt --version")
    '';
}
