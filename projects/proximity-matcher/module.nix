{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.proximity-matcher;
in
{
  options.services.proximity-matcher = {
    enable = lib.mkEnableOption "proximity-matcher";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.proximity-matcher;
      description = "The package to use.";
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The address the webservice should listen on.";
    };
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "The port the webservice should listen on.";
    };
    hashesPicklePath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the pickle with TLSH hashes.";
    };
    hashesPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file with TLSH hashes, formatted as one hash per line.

        It is only used with the optimized version of the server.
      '';
    };
    optimized = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use the optimized version of the server.";
    };
    workers = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "The number of workers gunicorn should use.";
    };
    timeout = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "The timeout in seconds for workers of the optimized server.";
    };
  };
  config = {
    systemd.services.proximity-matcher = lib.mkIf cfg.enable {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        PROXIMITY_CONFIGURATION = pkgs.writeText "proximity_config.py" (
          ''
            TLSH_PICKLE_FILE = '${cfg.hashesPicklePath}'
          ''
          + lib.optionalString (!(isNull cfg.hashesPath)) ''
            KNOWN_TLSH_HASHES = '${cfg.hashesPath}'
          ''
        );
      };
      serviceConfig = {
        ExecStart = "${
          lib.getExe' (pkgs.python3.withPackages (_: [ cfg.package ])) "gunicorn"
        } -w ${toString cfg.workers} -b ${cfg.listenAddress}:${toString cfg.listenPort} --preload${lib.optionalString cfg.optimized " -t ${toString cfg.timeout}"} proximity_matcher_webservice.proximity_server${lib.optionalString cfg.optimized "_opt"}:app";

        # from systemd-analyze --no-pager security proximity-matcher.service
        CapabilityBoundingSet = null;
        DynamicUser = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
