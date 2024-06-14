{
  sources,
  pkgs,
  lib,
  ...
}:
let
  storageBase = "/var/peertube";
  storageDir = subdir: "${storageBase}/${subdir}/";
  peerUser = "peertube";
  peerGroup = "peertube";
  localUser = "alice";
  pluginPkgs = with pkgs; [
    peertube-plugin-akismet
    peertube-plugin-auth-ldap
    peertube-plugin-auth-openid-connect
    peertube-plugin-auth-saml2
    peertube-plugin-auto-block-videos
    peertube-plugin-auto-mute
    peertube-plugin-hello-world
    peertube-plugin-matomo
    peertube-plugin-privacy-remover
    peertube-plugin-transcoding-custom-quality
    peertube-plugin-transcoding-profile-debug
    peertube-theme-dark
    peertube-plugin-livechat
  ];
in
{
  name = "peertube-plugins";

  nodes = {
    server =
      { config, ... }:
      {
        imports = [
          sources.modules.default
          sources.modules."services.peertube.plugins"
        ];

        # Interactive testing can run into OOM with default
        virtualisation.memorySize = 2047;

        users.users."${localUser}" = {
          description = localUser;
          password = "foobar";
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          uid = 1000;
        };

        services.xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
          windowManager.icewm.enable = true;
        };

        services.displayManager = {
          defaultSession = "none+icewm";
          autoLogin = {
            enable = true;
            user = localUser;
          };
        };

        environment = {
          # To ease with interactive testing, use a fixed password
          etc."peertube-envvars".text = ''
            PT_INITIAL_ROOT_PASSWORD=changeme
          '';
        };

        services.peertube = {
          enable = true;
          user = peerUser;
          group = peerGroup;
          secrets.secretsFile = pkgs.writeText "secrets.txt" "secrets";
          database.createLocally = true;
          redis.createLocally = true;
          localDomain = "localhost";
          listenWeb = 9000;
          dataDirs = [
            (storageDir "tmp")
            (storageDir "logs")
            (storageDir "cache")
            (storageDir "plugins")
          ];
          settings = {
            listen = {
              hostname = "0.0.0.0";
            };
            log = {
              level = "debug";
            };
            storage = {
              tmp = storageDir "tmp";
              logs = storageDir "logs";
              cache = storageDir "cache";
              plugins = storageDir "plugins";
            };
          };

          plugins = {
            enable = true;
            packages = pluginPkgs;
          };

          serviceEnvironmentFile = "/etc/peertube-envvars";
        };

        systemd.tmpfiles.settings =
          let
            dirArgs = {
              mode = "0700";
              user = peerUser;
              group = peerGroup;
            };
          in
          {
            "99-peertube-plugins-test-setup" = {
              "${storageBase}".d = dirArgs;
              "${storageDir "tmp"}".d = dirArgs;
              "${storageDir "logs"}".d = dirArgs;
              "${storageDir "cache"}".d = dirArgs;
              "${storageDir "plugins"}".d = dirArgs;
            };
          };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      with subtest("peertube works"):
          server.wait_for_unit("peertube.service")
          server.wait_for_console_text("Web server: http://localhost:9000")

      # Eventually peertube-plugins-initial kicks in, sets up the initial state
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} installs"):
          server.wait_for_console_text("Successful installation of plugin ${plugin}")
    '') pluginPkgs)
    + ''

      # peertube-plugins-initial triggers a restart and causes regular peertube-plugins to fire instead
      #server.wait_for_unit("peertube-plugins.service")

      # Plugins should all still come up
    ''
    + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} registers"):
          server.wait_for_console_text("Registering plugin or theme ${plugin.pname}")
    '') pluginPkgs)
    + ''

          # Now wait until we can get through to the instance
          server.wait_until_succeeds("curl -Ls http://localhost:9000")

      # And the plugins should now be loaded
      # FIXME: Order of tests must match order of the logs, otherwise earlier waits digest the message

      with subtest("peertube plugin ${pkgs.peertube-plugin-livechat.pname} works"):
          server.wait_for_console_text("loading peertube admins and moderators")

      with subtest("peertube plugin ${pkgs.peertube-plugin-hello-world.pname} works"):
          server.wait_for_console_text("hello world PeerTube admin")
    '';
}
