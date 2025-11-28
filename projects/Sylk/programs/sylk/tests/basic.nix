{
  sources,
  lib,
  ...
}:

{
  name = "Sylk (desktop client)";
  meta.maintainers = lib.teams.ngi.members;

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.sylk
          sources.examples.Sylk."Enable Sylk (desktop client)"

          # enable graphical session
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        services.xserver.enable = true;
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_x()

      machine.succeed("env DISPLAY=:0 sylk >&2 &")
      machine.wait_for_text("Sylk")
      machine.screenshot("sylk")
    '';
}
