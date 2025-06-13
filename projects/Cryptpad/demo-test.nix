{
  sources,
  ...
}:
{
  name = "cryptpad-demo";

  # TODO: just for debugging, remove after
  skipTypeCheck = true;
  skipLint = true;
  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
        ];

        # without this, qemu fails to allocate memory in the demo VM
        virtualisation.memorySize = 8192;
      };
  };

  testScript =
    { nodes, ... }:
    let
      demo-vm = sources.utils.demo.vm sources.examples.Cryptpad.demo;
      demo-system = sources.utils.demo.eval sources.examples.Cryptpad.demo;
      servicePort = demo-system.config.services.cryptpad.settings.httpPort;
    in
    ''
      start_all()

      machine.execute("${demo-vm} &>/dev/null &")
      machine.succeed("curl --silent --retry 10 --retry-max-time 120 --retry-all-errors http://localhost:${toString servicePort}/")
    '';
}
