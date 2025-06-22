{
  sources,
  ...
}:
{
  name = "slipshow presentation";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.slipshow
          sources.examples.slipshow.basic
        ];

        environment.etc."slipshow".source = pkgs.fetchFromGitHub {
          owner = "meithecatte";
          repo = "bbslides";
          rev = "ce1c08cafa71ae36dda8cc581956548b8386ae16";
          hash = "sha256-sOydmvtDeMhNejDkwlsXdrbwtqN6lcNnzTnGzBVRFxA=";
        };

      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # it may take around a minute to compile the file and serve it
      machine.succeed("slipshow serve /etc/slipshow/bbslides.md &>/dev/null &")

      # slipshow serves defaultly on :8080 and unfortunately cannot
      # be changed currently
      machine.wait_for_open_port(8080)
      machine.succeed("curl -i 0.0.0.0:8080")
    '';
}
