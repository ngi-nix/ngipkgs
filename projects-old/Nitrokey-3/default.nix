{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs)
      # TODO: nitrokey-3-firmware
      nitrokey-fido2-firmware
      nitrokey-pro-firmware
      nitrokey-start-firmware
      nitrokey-storage-firmware
      nitrokey-trng-rs232-firmware
      ;
  };
}
