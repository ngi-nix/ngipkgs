{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "Decentralized content aggregator and microblogging platform running on the Fediverse network.";
    subgrants = [
      "Kbin"
      "Kbin-Mobile"
    ];
  };

  nixos.programs = {
    kbin = {
      name = "kbin";
      module = ./programs/kbin/module.nix;
      examples.basic = {
        module = ./programs/kbin/examples/basic.nix;
        description = "";
        tests.basic = import ./programs/kbin/tests/basic.nix args;
      };
    };
  };

  nixos.services = {
    kbin = {
      name = "kbin";
      module = ./services/kbin/module.nix;
      examples.basic = {
        module = ./services/kbin/examples/basic.nix;
        description = "";
        tests.basic = import ./services/kbin/tests/basic.nix args;
      };
      links = {
        source = {
          text = "Build from source";
          url = "https://codeberg.org/Kbin/kbin-core";
        };
        docs = {
          text = "Documentation";
          url = "https://codeberg.org/Kbin/kbin-core/src/branch/develop/docs/user_guide.md";
        };
      };
    };
  };
}
