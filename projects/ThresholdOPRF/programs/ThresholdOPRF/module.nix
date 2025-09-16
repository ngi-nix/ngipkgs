{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ThresholdOPRF;
in
{
  options.programs.ThresholdOPRF = {
    enable = lib.mkEnableOption "ThresholdOPRF";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libopaque
      liboprf
      pwdsphinx
      python3Packages.opaque
      python3Packages.pyequihash
      python3Packages.pyoprf
      python3Packages.qrcodegen
    ];
  };
}
