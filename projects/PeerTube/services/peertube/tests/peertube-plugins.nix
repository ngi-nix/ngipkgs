{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "peertube-plugins";

  nodes = {
    server =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.peertube
          sources.examples.PeerTube.basic-server
        ];

        # Test every plugin
        services.peertube.plugins.plugins =
          with pkgs;
          lib.mkForce [
            # Official plugins
            peertube-plugin-akismet
            peertube-plugin-auth-ldap
            peertube-plugin-auth-openid-connect
            peertube-plugin-auth-saml2
            peertube-plugin-auto-block-videos
            peertube-plugin-auto-mute
            peertube-plugin-hello-world
            peertube-plugin-logo-framasoft
            peertube-plugin-matomo
            peertube-plugin-privacy-remover
            peertube-plugin-transcoding-custom-quality
            peertube-plugin-transcoding-profile-debug
            peertube-plugin-video-annotation
            peertube-theme-background-red
            peertube-theme-dark
            peertube-theme-framasoft

            # 3rd party plugins
            # FIX: https://github.com/ngi-nix/ngipkgs/issues/1943
            # peertube-plugin-livechat
          ];

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

      with subtest("peertube works"):
          server.wait_for_unit("peertube.service")
          server.wait_for_console_text("Web server: ${url}")

      # Eventually peertube-plugins-initial kicks in, sets up the initial state
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} installs"):
          server.wait_for_console_text("Successful installation of plugin ${plugin}")
    '') nodes.server.services.peertube.plugins.plugins)
    + ''

      # peertube-plugins-initial triggers a restart and causes regular peertube-plugins to fire instead
      # Plugins should all still come up
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} registers"):
          server.wait_for_console_text("Registering plugin or theme ${plugin.pname}")
    '') nodes.server.services.peertube.plugins.plugins)
    + ''

      # Now wait until we can get through to the instance and trigger some initial loading
      server.wait_until_succeeds("curl -Ls ${url}")

      # And the plugins should now be loaded
      # The order of the checks here is based on when different plugins emit their log messages

      with subtest("peertube plugin ${pkgs.peertube-plugin-hello-world.pname} works"):
          server.wait_for_console_text("hello world PeerTube admin")
    '';
}
