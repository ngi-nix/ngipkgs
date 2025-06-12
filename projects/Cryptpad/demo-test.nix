{
  sources,
  ...
}:
{
  name = "cryptpad-demo";

  skipTypeCheck = true;
  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      let
        demo-vm = sources.utils.demo-vm sources.examples.Cryptpad.demo;
      in
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
        ];

        environment.systemPackages = [ demo-vm ];

        virtualisation.memorySize = 8192;
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.execute("demo-vm &>/dev/null &")
      machine.succeed("curl --fail --retry 5 --connect-timeout 10 http://localhost:9000/") # TODO: get port from config
    '';
}
