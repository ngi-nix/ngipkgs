{
  lib,
  config,
  ...
}:
let
  cfg = config.services.pdfding;
in
{
  config = lib.mkIf cfg.enable {
    demo-vm = {
      # TODO what's this file?
    };
  };
}
