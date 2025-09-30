{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    ;

  settingsFormat = pkgs.formats.toml { };
  cfg = config.programs.tau-radio;
  configFile = settingsFormat.generate "config.toml" cfg.settings;
in
{
  options.programs.tau-radio = {
    enable = mkEnableOption "tau-radio";
    package = mkPackageOption pkgs "tau-radio" { };

    passwordFile = mkOption {
      type = with types; nullOr path;
      description = "Path that points to a file that contains the webradio server password.";
      default = null;
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          username = mkOption {
            type = types.str;
            description = "Webradio server username.";
          };
          password = mkOption {
            type = types.str;
            default = "@password@";
            description = "Webradio server password.";
            readOnly = true;
            internal = true;
          };
          ip = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Tau-tower server ip";
          };
          port = mkOption {
            type = types.port;
            default = 3001;
            description = "Tau-tower server port";
          };
          broadcast_port = mkOption {
            type = types.port;
            default = 3002;
            description = "Tau-tower broadcast port";
          };
          # TODO: verify that this is an enum and that these are the variants
          audio_interface = mkOption {
            type = types.enum [
              "jack"
              "oss"
              "pcm.sysdefault"
              "pipewire"
              "pulse"
              "alsa"
            ];
            default = "pipewire";
            description = "Audio interface.";
          };
          file = mkOption {
            type = types.str;
            default = "tau.ogg";
            description = "";
          };
        };
      };
      default = { };
      description = "Tau-radio config settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.password == "@password@";
        message = ''
          It's insecure to enter your password as cleartext.

          Use `services.tau-tower.passwordFile`, instead.
        '';
      }
    ];

    environment.etc."tau/config.toml".source = configFile;

    environment.systemPackages = [
      cfg.package
    ];
  };
}
