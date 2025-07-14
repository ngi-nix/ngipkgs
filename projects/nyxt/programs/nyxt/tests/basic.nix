{
  sources,
  ...
}:

{
  name = "nyxt";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.nyxt
          sources.examples.nyxt."Enable Nyxt"
        ];

        # not enough memory for the allocation
        virtualisation.memorySize = 4096;
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("nyxt --version")
    '';
}
