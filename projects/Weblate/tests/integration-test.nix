{
  sources,
  pkgs,
  ...
}: let
  certs = import "${sources.nixpkgs}/nixos/tests/common/acme/server/snakeoil-certs.nix";

  serverDomain = certs.domain;

  admin = {
    username = "admin";
    password = "snakeoilpass";
  };
  # An API token that we manually insert into the db as a valid one.
  apiToken = "OVJh65sXaAfQMZ4NTcIGbFZIyBZbEZqWTi7azdDf";
in {
  name = "weblate";
  meta.maintainers = with pkgs.lib.maintainers; [erictapen];

  nodes.server = {
    config,
    pkgs,
    lib,
    ...
  }: {
    virtualisation.memorySize = 2048;

    services.postgresql.package = pkgs.postgresql_14;

    imports = [sources.modules."services.weblate"];

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

    services.nginx.virtualHosts."${serverDomain}" = {
      enableACME = lib.mkForce false;
      sslCertificate = certs."${serverDomain}".cert;
      sslCertificateKey = certs."${serverDomain}".key;
    };

    services.postfix = {
      enableSubmission = true;
      enableSubmissions = true;
      submissionsOptions = {
        smtpd_sasl_auth_enable = "yes";
        smtpd_client_restrictions = "permit";
      };
      # sslKey = certs.${serverDomain}.key;
      # sslCert = certs.${serverDomain}.cert;
    };

    security.pki.certificateFiles = [certs.ca.cert];

    networking.hosts."::1" = ["${serverDomain}"];
    networking.firewall.allowedTCPPorts = [80 443];

    # We need weblate-env available to the root user.
    environment.systemPackages = config.users.users.weblate.packages;
    users.users.weblate.shell = pkgs.bashInteractive;
  };

  nodes.client = {
    pkgs,
    nodes,
    ...
  }: {
    environment.systemPackages = [pkgs.wlc];

    environment.etc."xdg/weblate".text = ''
      [weblate]
      url = https://${serverDomain}/api/
      key = ${apiToken}
    '';

    networking.hosts."${nodes.server.networking.primaryIPAddress}" = ["${serverDomain}"];

    security.pki.certificateFiles = [certs.ca.cert];
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
    # client.wait_until_succeeds("wlc --debug list-projects")

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

    # server.wait_for_unit("postfix.service")

    # The goal is for this to succeed, but there are still some checks failing.
    # server.succeed("sudo -iu weblate -- weblate-env weblate check --deploy")

  '';
}
