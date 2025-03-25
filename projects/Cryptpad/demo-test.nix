{
  sources,
  ...
}:
{
  name = "cryptpad-demo";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.cryptpad
          sources.examples.Cryptpad.demo
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("cryptpad.service")
      machine.wait_for_unit("nginx.service")
    '';
}
