{
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

  makeManPath = lib.makeSearchPathOutput "man" "share/man";

  activate =
    demo-shell:
    pkgs.writeShellApplication rec {
      name = "demo-shell";
      runtimeInputs = lib.attrValues demo-shell.programs;
      runtimeEnv = demo-shell.env;
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
          export PS1="\[\033[1m\][demo-shell]\[\033[m\]\040\w >\040"

          ${pkgs.lib.getExe pkgs.bash} --norc "$@"
        '';
    };
in
{
  options.demo-shell = mkOption {
    type =
      with types;
      submodule {
        options = {
          programs = mkOption {
            type = attrsOf package;
            description = "Set of programs that will be installed in the shell.";
            example = {
              embedded = pkgs.icestudio;
              messaging = pkgs.briar-desktop;
            };
            default = { };
          };
          env = mkOption {
            type = attrsOf str;
            description = "Set of environment variables that will be passed to the shell.";
            example = {
              XRSH_PORT = "9090";
            };
            default = { };
          };
        };
      };
    default = { };
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
            apply = self: activate config.demo-shell;
          };
        };
      };
    default = { };
  };

  # config.activate = config.shells.bash.activate;
}
