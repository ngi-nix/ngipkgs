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

  # https://github.com/ngi-nix/ngipkgs/issues/1512
  binary.lora-modem-firmware.data = null;

  nixos.modules = {
    # https://github.com/ngi-nix/ngipkgs/issues/1514
    programs.irdest-mblog.module = null;
    services = {
      ratmand = {
        module = ./services/ratmand/module.nix;
        examples.basic-ratmand = {
          module = ./services/ratmand/examples/basic.nix;
          description = "Basic ratmand configuration";
          tests = {
            ratmand-config.module = import ./services/ratmand/tests/config.nix args;
            peer-communication.module = import ./services/ratmand/tests/peer-communication.nix args;
          };
        };
      };
      # https://github.com/ngi-nix/ngipkgs/issues/1511
      irdest-proxy.module = null;
      # https://github.com/ngi-nix/ngipkgs/issues/1513
      irdest-echo.module = null;
    };
  };
}
