{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    instructions = mkOption {
      type =
        with types;
        either
          # cross-platform
          (submodule ./shell-session.nix)
          # platform-specific
          (
            listOf (submodule {
              options = {
                platform = mkOption {
                  type = str;
                };
                shell-session = mkOption {
                  type = submodule ./shell-session.nix;
                };
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
            <dl>
            ${lib.concatMapStringsSep "\n" (i: ''
              <dt>${i.platform}</dt>
              <dd>
                ${toString i.shell-session}
              </dd>
            '') self.instructions}
            </dl>
          ''
        else
          toString self.instructions;
    };
  };
}
