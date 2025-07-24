{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Local P2P mesh discovery of devices and users";
    subgrants = [
      "Irdest"
      "Irdest-OpenWRT-BLE"
      "Irdest-Proxy"
      "Irdest-Spec"
    ];
    links = {
      documentation = {
        text = "Documentation";
        url = "https://github.com/irdest/irdest/tree/develop/docs";
      };
      website = {
        text = "Website";
        url = "https://irde.st";
      };
    };
  };

  nixos.modules.programs.irdest.module = null;
  nixos.modules.services.irdest.module = null;
}
