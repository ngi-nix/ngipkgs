{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Modular decentralized peer-to-peer packet router and associated tools";
    subgrants = {
      Review = [ "Irdest" ];
      Core = [ "Irdest-Proxy" ];
      Entrust = [
        "Irdest-OpenWRT-BLE"
        "Irdest-Spec"
      ];
    };
    links = {
      documentation = {
        text = "Documentation";
        url = "https://codeberg.org/irdest/irdest/src/branch/main/docs/user/src/SUMMARY.md";
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
