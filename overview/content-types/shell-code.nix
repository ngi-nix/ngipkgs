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
    prompt = mkOption {
      type = types.str;
    };
    input = mkOption {
      type = types.lines;
    };
    output = mkOption {
      type = with types; nullOr lines;
      default = null;
    };
  };
}
