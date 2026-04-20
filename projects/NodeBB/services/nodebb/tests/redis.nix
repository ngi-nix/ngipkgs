{
  sources,
  ...
}:

{
  name = "NodeBB";

  nodes.machine = {
    imports = [
      sources.modules.ngipkgs
      sources.modules.services.nodebb
      sources.examples.NodeBB."Enable NodeBB with redis"
    ];
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("nodebb.service")
      machine.wait_for_open_port(${builtins.toString nodes.machine.services.nodebb.settings.port})

      machine.succeed("curl -v ${nodes.machine.services.nodebb.settings.url} >&2")
    '';

  # Debug interactively with:
  # - nix build -f . projects.NodeBB.tests.redis.driverInteractive -L && ./result/bin/nixos-test-driver
  # - start_all()/run_tests()
  # ssh -o User=root vsock%3 (can also do vsock/3, but % works with scp etc.)
  interactive.sshBackdoor.enable = true;
}
