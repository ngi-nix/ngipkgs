weblateModule:
{ pkgs, ... }:
{
  name = "weblate";
  meta.maintainers = with pkgs.lib.maintainers; [ erictapen ];

  nodes.server = { lib, ... }:
    {
      virtualisation.memorySize = 2048;

      imports = [ weblateModule ];

      services.weblate = {
        enable = true;
        localDomain = "example.org";
      };

      security.acme.email = "mail@example.org";
      security.acme.acceptTerms = true;

      networking.hosts."::1" = [ "example.org" ];
    };

  testScript = ''
    start_all()
    server.wait_for_unit("weblate.service")
    server.succeed("curl -f http://example.org/")
  '';
}
