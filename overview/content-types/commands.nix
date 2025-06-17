{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  # TODO: wrap in submodule and make it render itself
  commands = {
    bash = mkOption {
      type = with types; nullOr (submodule ./bash-code.nix);
      default = null;
    };
    # TODO: moar shells
  };
  session = mkOption {
    type = with types; nullOr (submodule ./shell-session.nix);
    default = null;
  };
in
{
  options = {
    instructions = mkOption {
      type =
        with types;
        either
          # cross-platform
          (submodule {
            options = {
              inherit commands session;
            };
          })
          # platform-specific
          (
            listOf (submodule {
              options = {
                platform = mkOption {
                  type = types.str;
                };
                inherit commands session;
              };
            })
          );
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        if lib.isList self.instructions then
          ''
            <ul>
            ${lib.concatMapStringsSep "\n" (i: ''
              <li>
                <summary>${i.platform}</summary>
                  ${toString i.commands.bash}
                  ${toString i.session}
              </li>
            '') self.instructions}
            </ul>
          ''
        else
          toString self.instructions.commands.bash;
    };
  };
}
