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

  makeManPath = lib.makeSearchPathOutput "man" "share/man";

  activate =
    demo-shell:
    pkgs.writeShellApplication rec {
      name = "demo-shell";
      runtimeInputs = lib.attrValues (lib.concatMapAttrs (name: value: value.programs) demo-shell);
      runtimeEnv = lib.concatMapAttrs (name: value: value.env) demo-shell;
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

          echo -e "\n\033[1;32mDemo shell activated! Available programs:\033[0m"
          ${lib.concatStringsSep "\n" (
            map (program: "echo '- ${program.pname} (${program.version})'") runtimeInputs
          )}

          # Display instructions if any exist
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: toString demo-shell.${name}) demo-shell
          )}
          echo -e

          ${pkgs.lib.getExe pkgs.bash} --norc "$@"
        '';
    };
in
{
  options.demo-shell = mkOption {
    type =
      with types;
      attrsOf (
        submodule (
          { name, ... }:
          {
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
              usage-instructions = mkOption {
                type = lines;
                description = "Instructions that will be shown to the user";
                example = ''
                  Run the `xrsh` command to start the web server.
                  Visit http://localhost:8080 in your browser to access the application.
                '';
                default = "";
              };
              __toString = mkOption {
                type = functionTo str;
                readOnly = true;
                default =
                  self:
                  lib.optionalString (self.usage-instructions != "") ''
                    echo -e "\n\033[1;34m=== ${name} Demo Usage Instructions ===\033[0m"
                    cat <<"EOF"
                    ${lib.trim self.usage-instructions}
                    EOF
                  '';
              };
            };
          }
        )
      );
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
          bash.activate = activate config.demo-shell;
        };
      };
    default = { };
  };
}
