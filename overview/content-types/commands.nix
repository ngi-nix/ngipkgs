{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
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
                    ${i.commands.bash}
                  </dd>
                </li>
              '') self.instructions}
            </ul>
          ''
        else
          ''
            ${self.instructions.commands.bash}
          '';
    };
  };
}
