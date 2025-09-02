{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open source web-based document editor";
    subgrants.Core = [
      "Wax"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://wax.is";
      };
      documentation = {
        text = "User guide";
        url = "https://www.wax.is/learn";
      };
      source = {
        text = "Source repository";
        url = "https://github.com/Wax-Platform/Wax";
      };
    };
  };

  nixos.modules.services.wax.module = null;
  nixos.modules.programs = {
    wax-client = {
      name = "wax-client";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/wax-client/module.nix;
      examples."Enable Wax web client" = {
        module = ./programs/wax-client/examples/basic.nix;
        tests.basic.module = null;
      };
    };
  };
}
