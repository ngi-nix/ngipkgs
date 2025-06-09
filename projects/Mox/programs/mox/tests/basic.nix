{
  sources,
  ...
}:

{
  name = "Mox";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.mox
          sources.examples.Mox.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # List available SMTP config examples
      machine.succeed("mox config example")
    '';
}
