{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.heads;
in
{
  # Note: Heads produces ROM images intended to be flashed onto real hardware.
  # This module only exists to allow automated testing of a QEMU-targeting
  # Heads ROM.
  options.programs.heads = {
    enable = lib.mkEnableOption "symlinking the Heads ROM for qemu-coreboot-fbwhiptail-tpm1-hotp";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."qemu-coreboot-fbwhiptail-tpm1-hotp.rom".source =
      "${pkgs.heads.qemu-coreboot-fbwhiptail-tpm1-hotp}/${pkgs.heads.qemu-coreboot-fbwhiptail-tpm1-hotp.passthru.romName}";
  };
}
