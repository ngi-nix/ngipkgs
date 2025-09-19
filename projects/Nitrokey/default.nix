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
    subgrants = {
      Review = [ "Nitrokey" ];
      Entrust = [ "Nitrokey-3" ];
      Commons = [
        "Nitrokey-Storage"
        "Nitrokey3-FIDO-L2"
      ];
    };
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

  binary = {
    # TODO: nitrokey-3-firmware
    "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
    "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
    "nitrokey-start-firmware".data = pkgs.nitrokey-start-firmware;
    "nitrokey-storage-firmware".data =
      if (system != "aarch64-linux") then pkgs.nitrokey-storage-firmware else null;
    "nitrokey-trng-rs232-firmware".data = pkgs.nitrokey-trng-rs232-firmware;
  };
}
