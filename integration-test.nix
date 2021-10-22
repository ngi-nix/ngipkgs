{ nixpkgs, weblateModule }:
{ pkgs, ... }:
let
  certs = import "${nixpkgs}/nixos/tests/common/acme/server/snakeoil-certs.nix";
  serverDomain = certs.domain;
  admin = {
    username = "admin";
    password = "snakeoilpass";
  };
  # An API token that we manually insert into the db as a valid one.
  apiToken = "OVJh65sXaAfQMZ4NTcIGbFZIyBZbEZqWTi7azdDf";
in
{
  name = "weblate";
  meta.maintainers = with pkgs.lib.maintainers; [ erictapen ];

  nodes.server = { config, pkgs, lib, ... }: {
    virtualisation.memorySize = 2048;

    imports = [ weblateModule ];

    services.weblate = {
      enable = true;
      localDomain = "${serverDomain}";
      djangoSecretKeyFile = pkgs.writeText "weblate-django-secret" "thisissnakeoilsecret";
      smtp = {
        createLocally = true;
        user = "weblate@${serverDomain}";
        passwordFile = pkgs.writeText "weblate-smtp-pass" "thisissnakeoilpassword";
      };
    };
    nixpkgs.overlays = [
      # The default timeout for the celery check is much too short upstream, so
      # we increase it. I guess this is due to the fact that we test the setup
      # very early into the initialization of the server, so the load might be
      # higher compared to production setups?
      (self: super: {
        weblate = super.weblate.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./longer-celery-wait-time.patch ];
        });
      })
    ];

    services.nginx.virtualHosts."${serverDomain}" = {
      enableACME = lib.mkForce false;
      sslCertificate = certs."${serverDomain}".cert;
      sslCertificateKey = certs."${serverDomain}".key;
    };

    security.pki.certificateFiles = [ certs.ca.cert ];

    networking.hosts."::1" = [ "${serverDomain}" ];
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # We need weblate-env available to the root user.
    environment.systemPackages = config.users.users.weblate.packages;
    users.users.weblate.shell = pkgs.bashInteractive;
  };

  nodes.client = { pkgs, nodes, ... }: {
    environment.systemPackages = [ pkgs.wlc ];

    environment.etc."xdg/weblate".text = ''
      [weblate]
      url = https://${serverDomain}/api/
      key = ${apiToken}
    '';

    networking.hosts."${nodes.server.config.networking.primaryIPAddress}" = [ "${serverDomain}" ];

    security.pki.certificateFiles = [ certs.ca.cert ];
  };

  testScript = ''
    import json

    start_all()
    server.wait_for_unit("weblate.socket")
    server.wait_until_succeeds("curl -f https://${serverDomain}/")
    server.succeed("sudo -iu weblate -- weblate-env weblate createadmin --username ${admin.username} --password ${admin.password} --email weblate@example.org")

    # It's easier to replace the generated API token with a predefined one than
    # to extract it at runtime.
    server.succeed("sudo -iu weblate -- psql -d weblate -c \"UPDATE authtoken_token SET key = '${apiToken}' WHERE user_id = (SELECT id FROM weblate_auth_user WHERE username = 'admin');\"")

    client.wait_for_unit("multi-user.target")

    # Test the official Weblate client wlc.
    client.succeed("wlc --debug list-projects")

    def call_wl_api(arg):
        (rv, result) = client.execute("curl -H \"Content-Type: application/json\" -H \"Authorization: Token ${apiToken}\" https://${serverDomain}/api/{}".format(arg))
        assert rv == 0
        print(result)

    call_wl_api("users/ --data '{}'".format(
      json.dumps(
        {"username": "test1",
          "full_name": "test1",
          "email": "test1@example.org"
        })))

  '';
}
