{
  lib,
  config,
  ...
}:
let
  cfg = config.services.reaction;
in
{
  config = lib.mkIf cfg.enable {
    demo-vm = {
      # TODO
    };
  };
}
