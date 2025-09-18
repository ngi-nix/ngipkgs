{
  sources,
  ...
}:

{
  name = "Serivce Name";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services._serviceName_
          sources.examples._ProjectName_._exampleName_
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
