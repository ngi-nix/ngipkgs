{ ... }:
{
  programs.heads = {
    enable = true;
    boards = [ "qemu-coreboot-fbwhiptail-tpm1-hotp" ];
    # The ROM image will be symlinked under /etc/heads/qemu-coreboot-fbwhiptail-tpm1-hotp.rom
  };
}
