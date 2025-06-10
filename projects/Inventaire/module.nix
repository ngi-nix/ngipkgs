{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.inventaire;
in
{
  options.services.inventaire = {
    enable = lib.options.mkEnableOption "Inventaire server";

    configOverridesFile = lib.options.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = ''
        Path to a .cjs file that exists at runtime with your desired settings overrides.

        The passed path will be set up as `config/local.cjs`.
      '';
      default = null;
    };

    stateDir = lib.options.mkOption {
      type = lib.types.path;
      description = ''
        Directory under which Inventaire will run.
      '';
      default = "/var/lib/inventaire";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      groups.inventaire = { };
      users.inventaire = {
        description = "User that runs Inventaire";
        home = cfg.stateDir;
        createHome = true;
        isSystemUser = true;
        group = "inventaire";
      };
    };

    systemd.services."inventaire" = {
      description = "Inventaire server";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "exec";
        User = "inventaire";
        Group = "inventaire";
        WorkingDirectory = cfg.stateDir;
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "inventaire-launch";

            runtimeInputs = with pkgs; [
              inventaire
            ];

            text =
              ''
                mkdir -p config db keys
                for configFile in ${pkgs.inventaire}/lib/node_modules/inventaire/config/*.cjs; do
                  ln -fs "$configFile" config/"$(basename "$configFile")"
                done
              ''
              + (
                if (cfg.configOverridesFile != null) then
                  ''
                    ln -fs ${cfg.configOverridesFile} config/local.cjs
                  ''
                else
                  ''
                    rm -f config/local.cjs
                  ''
              )
              + ''

                exec inventaire
              '';
          }
        );
      };
    };
  };
}
