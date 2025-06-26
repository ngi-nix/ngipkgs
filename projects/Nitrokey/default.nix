{
  lib,
  pkgs,
  sources,
  system,
  ...
}@args:

{
  metadata = {
    summary = "Open hardware for encryption and authentication";
    subgrants = [
      "Nitrokey"
      "Nitrokey-3"
    ];
  };

  nixos.modules.programs = {
    nitrokey = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };

  binary = lib.mkIf (system != "aarch64-linux") {
    # TODO: nitrokey-3-firmware
    "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
    "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
    "nitrokey-start-firmware".data = pkgs.nitrokey-start-firmware;
    "nitrokey-storage-firmware".data = pkgs.nitrokey-storage-firmware;
    "nitrokey-trng-rs232-firmware".data = pkgs.nitrokey-trng-rs232-firmware;
  };
}
