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
  nixos.modules.services = {
    wax-server = {
      name = "wax-server";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./services/wax-server/module.nix;
      examples."Enable Wax web server" = {
        module = ./services/wax-server/examples/basic.nix;
        tests.basic.module = import ./services/wax-server/tests/basic.nix args;
      };
    };
  };
}
