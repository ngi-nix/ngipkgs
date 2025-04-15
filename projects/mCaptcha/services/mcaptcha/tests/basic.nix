{
  sources,
  ...
}:

{
  name = "mcaptcha";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.mcaptcha
          sources.examples.mcaptcha.basic
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
