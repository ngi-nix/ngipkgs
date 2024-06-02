{ sources, pkgs, lib, ... }:
let
  storageBase = "/var/peertube";
  storageDir = subdir: "${storageBase}/${subdir}/";
  peerUser = "peertube";
  peerGroup = "peertube";
  localUser = "alice";
  pluginPkgs = with pkgs; [
    peertube-plugin-hello-world
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

        environment.systemPackages = with pkgs; [ firefox ];

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

      # Eventuall peertube-plugins-initial kicks in, sets up the initial state
    '' + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} installs"):
          server.wait_for_console_text("Successful installation of plugin ${plugin}")
    '') pluginPkgs) + ''

      # peertube-plugins-initial triggers a restart and causes regular peertube-plugins to fire instead
      #server.wait_for_unit("peertube-plugins.service")

      # Plugins should all still come up
    '' + (lib.strings.concatMapStringsSep "\n" (plugin: ''
      with subtest("peertube plugin ${plugin.pname} registers"):
          server.wait_for_console_text("Registering plugin or theme ${plugin.pname}")
    '') pluginPkgs) + ''

      with subtest("peertube plugin ${pkgs.peertube-plugin-hello-world.pname} works"):
          # Now wait until we can get through to the instance
          server.wait_until_succeeds("curl -Ls http://localhost:9000")

          # And the plugin should print something upon access
          server.wait_for_console_text("hello world PeerTube admin")
    '';
}
