{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  command = {
    bash = mkOption {
      type = types.submodule ./bash-code.nix;
    };
    # TODO: moar shells
  };
in
{
  options = {
    commands = mkOption {
      type =
        with types;
        listOf (submodule {
          options = command;
        });
      default = [ ];
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        lib.optionalString (self.commands != [ ]) ''
          <ul>
            ${lib.concatMapStringsSep "\n" (command: ''
              ${lib.optionalString (command ? bash) ''
                <li>${toString command.bash}</li>
              ''}
            '') self.commands}
          </ul>
        '';
    };
  };
}
