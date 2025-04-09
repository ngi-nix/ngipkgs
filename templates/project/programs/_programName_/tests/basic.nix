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
          sources.modules.programs._programName_
          sources.examples._ProjectName_._testName_  # i.e _ProjectName_.basic
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
