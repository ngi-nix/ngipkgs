{
  sources,
  ...
}:

{
  name = "Reaction basic";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.reaction
          sources.examples.Reaction.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed()
    '';
}
