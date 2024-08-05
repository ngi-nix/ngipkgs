{
  sources,
  lib,
  ...
}: let
  inherit
    (lib)
    mkForce
    ;
in {
  name = "atomic-server";

  nodes = {
    server = {
      config,
      lib,
      ...
    }: {
      imports = [
        sources.modules.default
        sources.modules."services.atomic-server"
        sources.modules.unbootable
        sources.examples."AtomicData/base"
      ];

      unbootable = mkForce false;

    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("atomic"):
        server.wait_for_unit("atomic-server.service")
        server.succeed("curl --fail --connect-timeout 10 http://localhost:9883/setup")
  '';
}
