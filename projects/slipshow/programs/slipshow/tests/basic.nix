{
  sources,
  ...
}:

{
  name = "slipshow";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.slipshow
          sources.examples.slipshow.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("slipshow --version")
    '';
}
