{ sources, ... }:

{
  name = "cryptolyzer-help";

  nodes = {
    machine =
      { ... }:
      let
        domain = "example.com";
      in
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.cryptolyzer
          sources.examples.CryptoLyzer."Enable CryptoLyzer"
        ];

        # set up a dns server -> unbound
        # set a local zone 'example.com' with an MX record
        services.unbound = {
          enable = true;
          resolveLocalQueries = true;
          # enable dnssec validation
          enableRootTrustAnchor = true;
          settings = {
            server = {
              interface = [ "127.0.0.1" ];
              access-control = [
                "127.0.0.1/8 allow"
                "::1/128 allow"
              ];
            };
            local-zone = [ ''"example.com." static'' ];
            local-data = [
              ''"${domain}. IN MX 10 mail.example.com"''
              ''"${domain}. IN A 127.0.0.1"''
            ];
          };
        };

        networking.nameservers = [ "127.0.0.1" ];
        networking.hosts = {
          "127.0.0.1" = [
            "${domain}"
          ];
        };

        # set up a http server -> nginx
        # add custom headers to analyze
        # disable SSL which is enabled defaultly
        services.nginx = {
          enable = true;
          virtualHosts."${domain}" = {
            locations."/" = {
              return = "200 'Hello World - Headers: $http_user_agent'";
              extraConfig = ''
                add_header Content-Type text/plain;
                add_header X-Test-Header "cryptolyzer-analysis";
                add_header Cache-Control "no-cache";
              '';
            };
            forceSSL = false;
          };

        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("multi-user.target")

      machine.succeed("cryptolyze --help")

      # analyze the MX record
      machine.succeed("cryptolyze dns mail example.com")

      # analyze dnssec
      machine.succeed("cryptolyze dns dnssec example.com")

      # analyze http headers
      machine.succeed("cryptolyze http headers http://example.com")

    '';
}
