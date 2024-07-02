{
  sources,
  pkgs,
  lib,
  ...
}: {
  name = "peertube-plugins";

  nodes = {
    server = {config, ...}: {
      imports = [
        sources.modules.default
        sources.modules."services.peertube.plugins"
        sources.examples."PeerTube/base"
      ];
    };
  };

  testScript = {nodes, ...}: let
    url = "http://${nodes.server.services.peertube.localDomain}:${toString nodes.server.services.peertube.listenWeb}";
  in
    ''
      start_all()

      with subtest("peertube works"):
          server.wait_for_unit("peertube.service")
          server.wait_for_console_text("Web server: ${url}")

      # Eventually peertube-plugins-initial kicks in, sets up the initial state
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
        with subtest("peertube plugin ${plugin.pname} installs"):
            server.wait_for_console_text("Successful installation of plugin ${plugin}")
      '')
      nodes.server.services.peertube.plugins.plugins)
    + ''

      # peertube-plugins-initial triggers a restart and causes regular peertube-plugins to fire instead
      # Plugins should all still come up
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
        with subtest("peertube plugin ${plugin.pname} registers"):
            server.wait_for_console_text("Registering plugin or theme ${plugin.pname}")
      '')
      nodes.server.services.peertube.plugins.plugins)
    + ''

      # Now wait until we can get through to the instance and trigger some initial loading
      server.wait_until_succeeds("curl -Ls ${url}")

      # And the plugins should now be loaded
      # The order of the checks here is based on when different plugins emit their log messages

      with subtest("peertube plugin ${pkgs.peertube-plugin-livechat.pname} works"):
          server.wait_for_console_text("loading peertube admins and moderators")

      with subtest("peertube plugin ${pkgs.peertube-plugin-hello-world.pname} works"):
          server.wait_for_console_text("hello world PeerTube admin")
    '';
}
