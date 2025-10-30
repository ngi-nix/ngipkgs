{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Openfire is a real time collaboration (RTC) server licensed under the Open Source Apache License.";
    subgrants.Core = [
      "Openfire-IPv6"
      "Openfire-Connectivity"
    ];
  };

  nixos.modules.services = {
    openfire-server = {
      name = "openfire-server";
      module = ./module.nix;
      examples.openfire-server = {
        module = ./example.nix;
        description = "";
        tests.basic.module = import ./test.nix args;
      };
    };
  };
}
