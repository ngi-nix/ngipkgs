{
  sources,
  lib,
  pkgs,
  ...
}:
{
  name = "Inventaire-basic";

  nodes = {
    machine =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.inventaire
          sources.examples.Inventaire.basic
        ];

        virtualisation.memorySize = 2048;
      };
  };

  # Need to see when terminals have launched
  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("inventaire.service")
      machine.wait_for_console_text("inventaire server is listening")
    '';
}
