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

    let
      elasticSearchEnabled = nodes.machine.services.elasticsearch.enable;
    in
    ''
      start_all()

      machine.wait_for_unit("inventaire.service")
    ''
    + (
      if elasticSearchEnabled then
        # With ElasticSearch, we can actually expect full startup & check that it works
        ''
          machine.wait_for_console_text("inventaire server is listening on port 3006")

          machine.succeed("env DISPLAY=:0 firefox http://localhost:3006 >&2 &")

          # Title of start page
          machine.wait_for_window("Inventaire - your friends and communities are your best library")

          # Default instance name (insecure example config doesn't override this)
          machine.wait_for_text("My Inventaire Instance")

          machine.screenshot("Inventaire-works")
        ''
      else
        # Without ElasticSearch, we only can get some vey early startup stuff done before we're stuck waiting for
        # a nonexistent ElasticSearch instance
        ''
          machine.wait_for_console_text("waiting for Elasticsearch")
        ''
    );
}
