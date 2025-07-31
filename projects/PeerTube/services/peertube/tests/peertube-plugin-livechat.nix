{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "peertube-plugin-livechat";

  nodes = {
    server =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.peertube
          sources.examples.PeerTube.basic-server
        ];

        services.peertube = {
          plugins.plugins = lib.mkForce [
            pkgs.peertube-plugin-livechat
          ];
          # Needed to get output detected by test
          settings.log.level = "debug";
        };

        boot.kernelPackages = pkgs.linuxPackages_latest;
      };
  };

  testScript =
    { nodes, ... }:
    let
      url = "http://${nodes.server.services.peertube.localDomain}:${toString nodes.server.services.peertube.listenWeb}";
    in
    ''
      start_all()

      # Wait until we can get through to the instance and trigger some initial loading
      server.wait_until_succeeds("curl -Ls ${url}")

      server.wait_for_console_text("loading peertube admins and moderators")
    '';
}
