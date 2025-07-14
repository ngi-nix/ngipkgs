{
  sources,
  pkgs,
  ...
}:
{
  name = "mox";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.mox
          sources.examples.Mox."Enable the Mox server"
        ];

        environment.systemPackages = with pkgs; [
          mox
          unbound
        ];
        environment.etc."resolv.conf".text = ''
          nameserver 127.0.0.1
        '';

        networking.nameservers = [ "127.0.0.1" ];
        networking.hosts = {
          "127.0.0.1" = [
            "com."
            "mail.example.com"
            "example.com"
          ];
        };

        # Use unbound as a local DNS resolver and dissable DNSSEC validation
        # Listen only on the localhost interface both for IPv4 and IPv6
        # Define a local zone for com. to redirect queries to localhost and provide a static response
        # Define static DNS records
        services.unbound = {
          enable = true;
          resolveLocalQueries = true;
          enableRootTrustAnchor = false;
          settings = {
            server = {
              interface = [ "127.0.0.1" ];
              access-control = [
                "127.0.0.1/8 allow"
                "::1/128 allow"
              ];
            };
            local-zone = [
              "\"com.\" redirect"
            ];
            local-data = [
              "\"com. IN NS localhost\""
              "\"localhost. IN A 127.0.0.1\""
            ];
          };
        };

        systemd.services.mox-setup = {
          description = "Mox Setup";
          wantedBy = [ "multi-user.target" ];
          requires = [
            "network-online.target"
            "unbound.service"
          ];
          after = [
            "network-online.target"
            "unbound.service"
          ];
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Wait for machine to be available
      machine.wait_for_unit("multi-user.target")

      # Verify the mox service is running
      machine.wait_for_unit("mox.service")

      # Verify config file exists
      machine.succeed("test -f /var/lib/mox/config/mox.conf")

      # Verify mox user was created
      machine.succeed("getent passwd mox")

      # Check if ports are listening (assuming default SMTP port)
      machine.wait_until_succeeds("ss -tln | grep ':25 '")

      # Test running the mox command
      machine.succeed("mox version")

      # Check logs for any errors
      machine.succeed("journalctl -u mox.service --no-pager | grep -v 'error|failed'")
    '';
}
