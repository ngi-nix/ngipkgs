{ nixpkgs, weblateModule }:
{ pkgs, ... }:
let
  certs = import "${nixpkgs}/nixos/tests/common/acme/server/snakeoil-certs.nix";
  serverDomain = certs.domain;
in
{
  name = "weblate";
  meta.maintainers = with pkgs.lib.maintainers; [ erictapen ];

  nodes.server = { lib, ... }: {
    virtualisation.memorySize = 2048;

    imports = [ weblateModule ];

    services.weblate = {
      enable = true;
      localDomain = "${serverDomain}";
      djangoSecretKeyFile = pkgs.writeText "weblate-django-secret" "thisissnakeoilsecret";
      smtp = {
        user = "weblate@${serverDomain}";
        passwordFile = pkgs.writeText "weblate-smtp-pass" "thisissnakeoilpassword";
      };
    };


    services.nginx.virtualHosts."${serverDomain}" = {
      enableACME = lib.mkForce false;
      sslCertificate = certs."${serverDomain}".cert;
      sslCertificateKey = certs."${serverDomain}".key;
    };

    security.pki.certificateFiles = [ certs.ca.cert ];

    networking.hosts."::1" = [ "${serverDomain}" ];

  };

  testScript = ''
    start_all()
    server.wait_for_unit("weblate.service")
    server.wait_until_succeeds("curl -f https://${serverDomain}/")
  '';
}
