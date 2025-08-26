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

  nixos.modules = {
    services.ratmand = {
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
  };
}
