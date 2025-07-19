{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "oku demo";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.oku
          sources.examples.oku."Enable Oku"
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

      with subtest("Wait until Oku has finished loading the Valgrind docs page"):
        machine.execute("xterm -e 'oku -n file://${pkgs.valgrind.doc}/share/doc/valgrind/html/index.html' >&2 &");
        machine.wait_for_window("oku")
    '';
}
