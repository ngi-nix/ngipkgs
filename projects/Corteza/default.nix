{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open source low-code platform";
    subgrants = [
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
    examples.basic = {
      module = ./example.nix;
      description = "Basic example";
      tests.basic.module = pkgs.nixosTests.corteza;
    };
  };
}
