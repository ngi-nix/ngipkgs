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
            <div class=tabs>
              {% set input_group_name = unique_id() %}
              ${lib.concatStringsSep "\n" (
                # Enumerate over `self.instructions`.
                lib.zipListsWith (i: instruction: ''
                  {% set input_id = unique_id() %}
                  <input id="{{ input_id }}" type="radio" name="{{ input_group_name }}" ${
                    lib.optionalString (i == 1) "checked"
                  }>
                  <label for="{{ input_id }}" >${instruction.platform}</label>
                  <div class="tab-content">
                    ${toString instruction.shell-session}
                  </div>
                '') (lib.range 1 (lib.length self.instructions)) self.instructions
              )}
            </div>
          ''
        else
          toString self.instructions;
    };
  };
}
