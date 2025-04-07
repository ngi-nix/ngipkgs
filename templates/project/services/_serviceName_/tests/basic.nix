{
  sources,
  ...
}:

{
  name = "Service Name";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services._serviceName_
          sources.examples._ProjectName_._serviceName_
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
