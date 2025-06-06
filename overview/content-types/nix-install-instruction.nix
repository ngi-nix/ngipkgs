{
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
    };
    commands = {
      bash = mkOption {
        type = types.submodule ./bash-code.nix;
      };
      # TODO: moar shells
    };
  };
}
