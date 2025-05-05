{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Open hardware for encryption and authentication";
    subgrants = [
      "Nitrokey"
      "Nitrokey-3"
    ];
  };

  nixos.programs = {
    nitrokey = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };

  binary =
    # Depends on the system
    # see https://github.com/ngi-nix/ngipkgs/pull/773
    if builtins ? currentSystem then
      {
        # TODO: nitrokey-3-firmware
        "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
        "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
        "nitrokey-start-firmware".data = pkgs.nitrokey-start-firmware;
        "nitrokey-storage-firmware".data = pkgs.nitrokey-storage-firmware;
        "nitrokey-trng-rs232-firmware".data = pkgs.nitrokey-trng-rs232-firmware;
      }
    else
      { };
}
