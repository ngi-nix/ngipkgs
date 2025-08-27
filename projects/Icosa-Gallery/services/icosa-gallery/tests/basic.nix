{
  sources,
  ...
}:

{
  name = "Icosa Gallery";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.icosa-gallery
          sources.examples.Icosa-Gallery."Enable icosa-gallery"
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
