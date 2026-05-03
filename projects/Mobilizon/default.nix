{
  pkgs,
  lib,
  ...
}@args:
{
  metadata = {
    summary = "Free, libre and federated groups and events management platform";
    subgrants = {
      Commons = [
        "Empowering-Mobilizon"
      ];
      Core = [
        "Mobilizon-UX"
      ];
      Review = [
        "Mobilizon"
      ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://mobilizon.org/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.mobilizon.org/";
      };
      source = {
        text = "Source Code";
        url = "https://framagit.org/framasoft/mobilizon";
      };
    };
  };

  nixos.modules.services = {
    mobilizon = {
      module = lib.moduleLocFromOptionString "services.mobilizon";
      examples.prod = {
        module = ./example.nix;
        description = "A basic setup to run Mobilizon in an production environment";
        tests.basic.module = pkgs.nixosTests.mobilizon;
      };
    };
  };

  # TODO: test that credentials work properly
  nixos.demo = null;
}
