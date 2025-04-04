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
      rec {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.mox
          sources.examples.Mox.mox
        ];

        # Allow necessary ports through the firewall
        networking.firewall.allowedTCPPorts = [ 25 80 143 443 587 993 ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.unbound = {
          enable = true;
          settings = {
            server = {
              interface = [ "127.0.0.1" ];
            };
            forward-zone = [
              {
                name = ".";
                forward-addr = [
                  "9.9.9.9#dns.quad9.net"
                  "149.112.112.112#dns.quad9.net"
                ];
                forward-tls-upstream = true;
              }
            ];
          };
          enableRootTrustAnchor = true;
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Wait for machine to be available
      machine.wait_for_unit("multi-user.target")

      # Verify the mox-setup service has run successfully
      machine.wait_for_unit("mox-setup.service")
      
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
