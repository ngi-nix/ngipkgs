{
  sources,
  ...
}:

{
  name = "Tau Server";

  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.tau-tower
          sources.examples.Tau."Enable tau-tower"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("tau-tower.service")
      machine.wait_for_console_text("Broadcasting on")
    '';
}
