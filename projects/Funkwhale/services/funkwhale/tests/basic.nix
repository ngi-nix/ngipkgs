{
  sources,
  ...
}:
{
  name = "funkwhale-basic";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.funkwhale
          sources.examples.Funkwhale."Basic local configuration"
        ];

        services.typesense = {
          enable = true;
          settings.server.api-address = "localhost";
          apiKeyFile = pkgs.writeText "surely-not-in-store" "publicly-secret-key";
        };
        services.funkwhale.settings.TYPESENSE_API_KEY = "publicly-secret-key";

        # Protection from the ruthless OOM Killer.
        virtualisation.memorySize = 1536;
      };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("funkwhale-server.service")
    machine.wait_for_unit("funkwhale-beat.service")
    machine.wait_for_unit("funkwhale-worker.service")
    machine.wait_for_unit("funkwhale.target")

    # Website is served.
    machine.succeed("curl --fail http://localhost")

    # Can create supseruser and login.
    machine.succeed("sudo -u funkwhale funkwhale-manage fw users create --superuser "
                    "--username testinahat --email test@example.com --password teast1997")
    machine.succeed('curl --fail http://localhost/api/v2/users/login '
                    '--form "username=testinahat" --form "password=teast1997" '
                    '-H "X-CSRFToken: 00000000000000000000000000000000" '
                    '--cookie "csrftoken=00000000000000000000000000000000"')

    # Typesense integration works.
    machine.succeed("sudo -u funkwhale funkwhale-manage generate_typesense_index")
    machine.wait_for_console_text("typesense\\.build_canonical_index.*succeeded")
  '';
}
