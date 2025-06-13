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
      type = types.submodule ./bash-code.nix;
    };
    # TODO: moar shells
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
              inherit commands;
            };
          })
          # platform-specific
          (
            listOf (submodule {
              options = {
                platform = mkOption {
                  type = types.str;
                };
                inherit commands;
              };
            })
          );
    };
    render-codeblock = mkOption {
      type = with types; functionTo str;
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
              <dt>${i.platform}</dt>
              <dd>
              ${self.render-codeblock {
                content = toString i.commands.bash;
                copyableContent = i.commands.bash.input;
              }}
              </dd>
              </li>
            '') self.instructions}
            </ul>
          ''
        else
          self.render-codeblock {
            content = toString self.instructions.commands.bash;
            copyableContent = self.instructions.commands.bash.input;
          };
    };
  };
}
