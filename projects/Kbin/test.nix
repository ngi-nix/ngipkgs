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
  name = "kbin";

  nodes = {
    server = {
      config,
      lib,
      ...
    }: {
      imports = [
        sources.modules.default
        sources.modules."services.kbin"
        sources.modules.unbootable
        sources.examples."Kbin/base"
      ];

      unbootable = mkForce false;

      services.phpfpm.pools.kbin = {
        settings = {
          "pm.start_servers" = 1;
          "pm.min_spare_servers" = 1;
        };
        phpOptions = mkForce ''
          error_log = stderr
          log_errors = on
          error_reporting = E_ALL

          upload_max_filesize = 8M
          post_max_size = 8M
          memory_limit = 128M
        '';
      };
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("kbin"):
        server.wait_for_unit("phpfpm-kbin.service")
        server.succeed("kbin-console kbin:user:create admin admin@localhost admin");
        server.succeed("kbin-console kbin:user:admin admin");
        server.succeed("kbin-console kbin:ap:keys:update");

        server.wait_for_unit("nginx.service")
        server.succeed("curl --fail --connect-timeout 10 http://localhost/u/admin")
  '';
}
