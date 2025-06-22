{
  sources,
  fetchurl,
  ...
}:
{
  name = "slipshow presentation";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.slipshow
          sources.examples.slipshow.demo-shell
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      mdfile = fetchurl {
        url = "https://github.com/panglesd/slipshow/blob/v0.2.0/example/campus-du-libre/slipshow.md";
        hash = "sha256-4+ow0GQ8RAIYDDM6rg69/X4aYs9GgqFSuEjTJmAoG8A=";
      };
    in
    ''
      start_all()

      # it may take around a minute to compile the file and serve it
      machine.succeed("slipshow serve ${mdfile} &")

      # slipshow serves defaultly on :8080
      machine.wait_for_open_port(8080)
      machine.succeed("curl -i 0.0.0.0:8080")
    '';
}

