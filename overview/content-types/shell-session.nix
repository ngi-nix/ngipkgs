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
    bash = mkOption {
      type = with types; listOf (submodule ./bash-command.nix);
      default = [ ];
    };
    # TODO: moar shells
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        <dl>
          ${lib.optionalString (self.bash != [ ]) ''
            <dt>Bash</dt>
            <dd>
              ${lib.concatStringsSep "\n" self.bash}
            </dd>
          ''}
        </dl>
      '';
    };
  };
}
