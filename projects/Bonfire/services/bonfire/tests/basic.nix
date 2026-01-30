{
  sources,
  ...
}:

{
  name = "Bonfire";

  nodes = {
    machine =
      { pkgs, lib, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.bonfire
          sources.examples.Bonfire."Enable bonfire"
        ];

        # Explanation: increased to avoid:
        # Kernel panic - not syncing: Out of memory
        # as soon as running the initial migration of the PostgreSQL schema.
        virtualisation.memorySize = 4096;

        environment.systemPackages = [
          # ToDo: check if those are required here
          pkgs.firefox-unwrapped
          pkgs.geckodriver
          (pkgs.callPackage ./selenium.nix { })
        ];
      };
  };

  interactive = {
    # HowTo(maint/debug):
    # nix -L run -f . hydrated-projects.Bonfire.nixos.tests.basic.driverInteractive
    # python> start_all()
    # ssh -o User=root vsock/3
    sshBackdoor.enable = true;

    nodes.machine =
      { pkgs, ... }:
      {
        networking.firewall.allowedTCPPorts = [ 80 ];
        virtualisation.forwardPorts = [
          # HowTo(maint/debug):
          # nix -L run -f . hydrated-projects.Bonfire.nixos.tests.basic.driverInteractive
          # python> start_all()
          # firefox http://localhost:4000
          {
            from = "host";
            host.port = 4000;
            guest.port = 80;
          }
        ];

      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("postgresql.target")
      machine.wait_for_unit("nginx.service")

      with subtest("start bonfire"):
        machine.wait_for_unit("bonfire.service")
        machine.wait_for_open_port(${toString nodes.machine.config.services.bonfire.settings.PUBLIC_PORT})
        machine.wait_for_open_port(${toString nodes.machine.config.services.bonfire.settings.SERVER_PORT})

      # ToDo(security): whenever bonfire supports Unix socket
      # with subtest("check bonfire socket"):
      #   socket="/run/bonfire/socket"
      #   machine.wait_for_file(socket)
      #   machine.succeed(
      #     f'[[ "$(stat -c %U {socket})" == "bonfire" ]]',
      #     f'[[ "$(stat -c %G {socket})" == "bonfire" ]]',
      #     f'[[ "$(stat -c %a {socket})" == "660" ]]',
      #   )

      with subtest("Web interface"):
        machine.succeed("PYTHONUNBUFFERED=1 selenium-test")
    '';
}
