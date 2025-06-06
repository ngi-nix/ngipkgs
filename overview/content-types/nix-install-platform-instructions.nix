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
      type = with types; listOf (submodule ./nix-install-instruction.nix);
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default = self: ''
        <strong>Install Nix</strong>
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
      '';
    };
  };
}
