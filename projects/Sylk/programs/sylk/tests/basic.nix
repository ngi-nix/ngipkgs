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

          # enable graphical session + users (alice, bob)
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
          "${sources.inputs.nixpkgs}/nixos/tests/common/user-account.nix"
        ];

        test-support.displayManager.auto.user = "alice";
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_x()

      machine.succeed("su - alice -c 'DISPLAY=:0 sylk >&2 &'")
      machine.wait_for_text(r"(Sylk|Sign|In|Up|account|Password)")
      machine.screenshot("sylk")
    '';
}
