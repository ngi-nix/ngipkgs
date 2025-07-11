{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "nyxt demo";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.nyxt
          sources.examples.nyxt."Enable Nyxt"
          # sets up x11 with autologin
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        # not enough memory for the allocation
        virtualisation.memorySize = 8192;
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.wait_for_x()

      with subtest("Wait until Nyxt has finished loading the Valgrind docs page"):
        machine.execute("xterm -e 'nyxt file://${pkgs.valgrind.doc}/share/doc/valgrind/html/index.html' >&2 &");
        machine.wait_for_window("nyxt")
    '';
}
