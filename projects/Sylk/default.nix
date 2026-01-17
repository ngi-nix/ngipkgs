{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Secure multiparty videoconferencing application";
    subgrants = {
      Commons = [
        "SylkContact"
      ];
      Review = [
        "SylkChat"
        "SylkClient"
        "SylkMobile"
        "sylkRTC"
      ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/AGProjects";
      };
      homepage = {
        text = "Homepage";
        url = "https://sylkserver.com";
      };
      docs = {
        text = "Documentation";
        url = "https://sylkserver.com/documentation/";
      };
    };
  };

  nixos.modules.programs = {
    sylk = {
      module = ./programs/sylk/module.nix;
      examples."Enable Sylk (desktop client)" = {
        module = ./programs/sylk/examples/basic.nix;
        tests.client.module = ./programs/sylk/tests/basic.nix;
      };
    };
  };

  # replace test and module with upstream's when it's merged
  # https://github.com/NixOS/nixpkgs/pull/463656
  nixos.modules.services = {
    sylkserver = {
      module = ./services/sylkserver/module;
      examples."Enable Sylk (server)" = {
        module = ./services/sylkserver/examples/basic.nix;
        tests.server.module = ./services/sylkserver/tests/basic.nix;
      };
    };
  };

  nixos.demo = null;
}
