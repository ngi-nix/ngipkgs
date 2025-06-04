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
    platform = mkOption {
      type = types.str;
      readOnly = true;
      default = name;
    };
    commands = {
      bash = mkOption {
        type = types.submodule ./bash-code.nix;
      };
      # TODO: moar shells
    };
  };
}
