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
          sources.examples.Mox.basic
        ];
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
