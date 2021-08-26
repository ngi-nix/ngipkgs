weblateModule:
{ pkgs, ... }:
{
  name = "weblate";
  meta.maintainers = with pkgs.lib.maintainers; [ erictapen ];

  nodes.weblate = { lib, ... }:
    {
      virtualisation.memorySize = 2048;

      imports = [ weblateModule ];

      services.weblate = {
        enable = true;
        localDomain = "example.org";
      };

      security.acme.email = "mail@example.org";
      security.acme.acceptTerms = true;
    };

  testScript =
    ''
      start_all()
      # weblate.wait_for_unit("multi-user.target")
      weblate.wait_for_unit("weblate.service")
    '';
}
