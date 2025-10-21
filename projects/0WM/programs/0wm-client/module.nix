{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.programs.zwm-client;
  cfgServer = config.services.zwm-server;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "config.json" cfg.settings;
in
{
  options.programs.zwm-client = {
    enable = lib.mkEnableOption "0wm-client";
    package = lib.mkPackageOption pkgs "_0wm-client" { };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          api = mkOption {
            type = types.str;
            default = "http://${cfgServer.settings.interface}:${toString cfgServer.settings.port}";
            description = "0WM server address";
          };
        };
      };
      default = { };
      description = "0WM config settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # no other easy way to specify the config file, but to replace it
      (cfg.package.overrideAttrs (prev: {
        postFixup = prev.postFixup + ''
          rm $out/config.json
          install -m 600 ${configFile} $out/config.json
        '';
      }))

      # TODO: hide behind a debug option?
      pkgs._0wm-opmode
      pkgs._0wm-ap-mock
    ];
  };
}
