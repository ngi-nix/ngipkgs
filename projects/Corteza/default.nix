{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open source low-code platform";
    subgrants.Review = [
      "CortezaDiscovery"
      "CortezaFederationPrivacy"
      "CortezaActivityPub"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://cortezaproject.org/";
      };
      src = {
        text = "Source code";
        url = "https://github.com/cortezaproject/corteza";
      };
      example = {
        text = "Usage examples";
        url = "https://docs.cortezaproject.org/";
      };
    };
  };

  nixos.modules.services.corteza = {
    name = "Corteza";
    module = lib.moduleLocFromOptionString "services.corteza";
    examples."Enable Corteza" = {
      module = ./example.nix;
      tests.basic.module = pkgs.nixosTests.corteza;
    };
  };

  nixos.demo.vm = {
    module = ./demo-vm.nix;
    description = "Deployment for demo purposes";
    tests.basic.module = pkgs.nixosTests.corteza;
  };
}
