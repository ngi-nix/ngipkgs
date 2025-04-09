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
          sources.modules.services._programName_
          sources.examples._ProjectName_._programName_
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
