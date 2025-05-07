{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "Openfire is a real time collaboration (RTC) server licensed under the Open Source Apache License.";
    subgrants = [
      "Openfire-IPv6"
      "Openfire-Connectivity"
    ];
  };

  nixos.services = {
    openfire-server = {
      name = "openfire-server";
      module = ./module.nix;
      examples.openfire-server = {
        module = ./example.nix;
        description = "";
        tests.basic = import ./test.nix args;
      };
    };
  };
}
