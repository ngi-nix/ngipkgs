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
          (sources.inputs.nixpkgs + "/nixos/tests/common/x11.nix")
          sources.modules.ngipkgs
          sources.modules.services.inventaire
          sources.examples.Inventaire.basic
        ];

        # couchdb + elasticsearch eats up memory
        # leave some overhead for interactive firefox usage
        virtualisation.memorySize = 4096;

        environment.systemPackages = with pkgs; [
          firefox
        ];
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
