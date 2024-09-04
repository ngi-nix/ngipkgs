{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.marginalia-search;
in {
  options.services.marginalia-search = {
    enable = lib.mkEnableOption ''
      Marginalia Search, a search engine for a more human, non-commercial internet
    '';

    mariadb = {
      host = lib.mkOption {
        type = lib.types.string;
        description = "The host where the MarioDB database that Marginalia will use is located";
        default = "localhost";
      };
      user = lib.mkOption {
        type = lib.types.string;
        description = "The MarioDB database user Marginalia will use";
        default = "marginalia";
      };
      password = lib.mkOption {
        type = lib.types.string;
        description = "The MarioDB database user's password Marginalia will use (THIS IS WORLD-READABLE!)";
        default = "hunter2";
      };
    };

    zookeeper = {
      host = lib.mkOption {
        type = lib.types.string;
        description = "The host where the Apache Zookeeper instance that Marginalia will use is located";
        default = "localhost";
      };
      port = lib.mkOption {
        type = lib.types.string;
        description = "The port over which Marginalia should talk to Apache Zookeeper";
        default = "2181";
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    services.peertube.package = cfg.package.overrideAttrs (oa: {
      # yarn can't handle npm caches, and we can't build npm packages with our yarn tooling
      # Working on getting declarative plugin management into upstream to avoid this: https://github.com/Chocobozzz/PeerTube/issues/6428
      postPatch =
        (oa.postPatch or "")
        + ''
          substituteInPlace server/core/lib/plugins/yarn.ts \
            --replace-fail 'yarn ''${command}' 'npm --offline ''${command}'
        '';
    });

    systemd.services = {
      peertube-plugins-initial = null; #mkPluginService false;
      peertube-plugins = null; #mkPluginService true;
    };
  };

  meta.maintainers = [];
}
