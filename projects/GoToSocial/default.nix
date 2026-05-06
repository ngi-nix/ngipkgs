{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "GoToSocial is an ActivityPub social network server, written in Golang.";
    subgrants = {
      Commons = [
        "GoToSocial-1.0"
      ];
      Entrust = [
        "GoToSocial"
        "GoToSocial-scale"
      ];
    };
    links = {
      docs = {
        text = "Documentation";
        url = "https://docs.gotosocial.org";
      };
      homepage = {
        text = "Homepage";
        url = "https://gotosocial.org";
      };
      repo = {
        text = "Source repository";
        url = "https://codeberg.org/superseriousbusiness/gotosocial";
      };
    };
  };

  nixos.modules.services = {
    gotosocial = {
      name = "GoToSocial";
      module = lib.moduleLocFromOptionString "services.gotosocial";
      examples.basic = {
        module = ./services/gotosocial/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.gotosocial;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://codeberg.org/superseriousbusiness/gotosocial/src/branch/main/CONTRIBUTING.md#development";
        };
        test = {
          text = "Test instructions";
          url = "https://codeberg.org/superseriousbusiness/gotosocial/src/branch/main/CONTRIBUTING.md#testing";
        };
      };
    };
  };
}
