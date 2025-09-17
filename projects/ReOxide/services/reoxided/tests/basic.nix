{
  sources,
  ...
}:
{
  name = "reoxide";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.reoxide
          sources.modules.services.reoxided
          sources.examples.ReOxide."Enable reoxided"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()
    '';
}
