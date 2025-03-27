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
          # Sources module path depends on your folder structure
          ./module.nix
        ];

        # Configure the mox service
        services.mox = {
          enable = true;
          hostname = "mail.example.com";
          user = "admin@example.com";
        };

        # Allow necessary ports through the firewall
        networking.firewall.allowedTCPPorts = [ 25 143 587 993 ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Wait for machine to be available
      machine.wait_for_unit("multi-user.target")

      # Verify the mox-setup service has run successfully
      # machine.wait_for_unit("mox-setup.service")
      
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
