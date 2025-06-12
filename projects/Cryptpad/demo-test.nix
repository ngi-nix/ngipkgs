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
      let
        demo-vm = sources.utils.demo.vm sources.examples.Cryptpad.demo;
      in
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
        ];

        environment.systemPackages = [ demo-vm ];

        # without this, qemu fails to allocate memory in the demo VM
        virtualisation.memorySize = 8192;
      };
  };

  testScript =
    { nodes, ... }:
    let
      demo-system = sources.utils.demo.eval sources.examples.Cryptpad.demo;
      servicePort = demo-system.config.services.cryptpad.settings.httpPort;
    in
    ''
      start_all()

      machine.execute("demo-vm &>/dev/null &")
      machine.succeed("curl --silent --retry 10 --retry-max-time 120 --retry-all-errors http://localhost:${toString servicePort}/")
    '';
}
