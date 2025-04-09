{
  sources,
  ...
}:
{
  name = "keyoxide-cli";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.keyoxide-cli
          sources.examples.Keyoxide.keyoxide-cli
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("keyoxide --help")
    '';
}
