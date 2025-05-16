{
  sources,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

  mapAppsToList =
    app-shell: lib.flatten (map (name: lib.attrValues name.programs) (lib.attrValues app-shell));

  makeManPath = lib.makeSearchPathOutput "man" "share/man";

  activate =
    apps:
    pkgs.writeShellApplication rec {
      name = "demo-shell";
      runtimeInputs = apps;
      passthru.inheritManPath = false;
      # HACK: start shell from ./result
      derivationArgs.postCheck = ''
        mv $out/bin/$name /tmp/$name
        rm -rf $out && mv /tmp/$name $out
      '';
      text =
        lib.optionalString (runtimeInputs != [ ]) ''
          export MANPATH="${makeManPath runtimeInputs}${lib.optionalString passthru.inheritManPath ":$MANPATH"}"
        ''
        + ''
          export PS1="\[\033[1m\][app-shell]\[\033[m\]\040\w >\040"

          ${pkgs.lib.getExe pkgs.bash} --norc "$@"
        '';
    };
in
{
  options.app-shell = mkOption {
    type =
      with types;
      attrsOf (submodule {
        options = {
          programs = mkOption {
            type = attrsOf package;
            description = "Set of programs that will be installed in the shell.";
            example = {
              geospatial = pkgs.qgis;
            };
            default = { };
          };
        };
      });
  };

  options.shells = mkOption {
    type =
      with types;
      submodule {
        options = {
          bash.enable = mkOption {
            type = bool;
            default = true;
          };
          bash.activate = mkOption {
            type = nullOr package;
            default = null;
          };
        };
        config = lib.mkIf config.shells.bash.enable {
          bash.activate = activate (mapAppsToList config.app-shell);
        };
      };
    default = { };
  };
}
