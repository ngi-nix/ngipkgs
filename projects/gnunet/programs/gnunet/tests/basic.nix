{
  sources,
  ...
}:

{
  name = "gnunet";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.gnunet
          sources.examples.gnunet.basic
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
