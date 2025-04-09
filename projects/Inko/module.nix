{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.inko;
in
{
  options.programs.inko = {
    enable = lib.mkEnableOption "inko";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inko
      ivm
    ];
  };
}
