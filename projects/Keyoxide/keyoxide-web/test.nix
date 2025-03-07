{
  sources,
  ...
}:
{
  name = "keyoxide-web";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.keyoxide
          sources.examples.Keyoxide.keyoxide-web
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("curl -v http://localhost:3000")
    '';
}
