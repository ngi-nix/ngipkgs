{
  configurations,
  modules,
}: {
  name = "kbin";

  nodes = {
    server = {config, ...}: {
      imports = [
        modules.default
        modules.kbin
      ];

      services.kbin = {
        enable = true;
      };
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("rosenpass"):
        server.wait_for_unit("kbin.service")
  '';
}
