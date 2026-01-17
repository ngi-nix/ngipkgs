{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Rosenpass is a formally verified, post-quantum secure VPN that uses WireGuard to transport the actual data.";
    subgrants = {
      Core = [
        "Rosenpass-integration"
      ];
      Review = [
        "Rosenpass"
        "Rosenpass-API"
      ];
    };
    links = {
      docs = {
        text = "Rosenpass documentation";
        url = "https://rosenpass.eu/docs/";
      };
      docker = {
        text = "Rosenpass in Docker";
        url = "https://github.com/rosenpass/rosenpass/blob/main/docker/USAGE.md";
      };
      build = {
        text = "Build from source";
        url = "http://rosenpass.eu/docs/rosenpass-tool/compilation/#installation-via-binary-files";
      };
    };
  };

  nixos.modules.programs = {
    rosenpass = {
      name = "rosenpass";
      module = ./programs/basic/module.nix;
      examples.basic = {
        module = ./programs/basic/examples/basic.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };

  nixos.modules.services = {
    rosenpass = {
      name = "rosenpass";
      module = lib.moduleLocFromOptionString "services.rosenpass";
      examples.basic = {
        module = ./services/basic/examples/basic.nix;
        description = "";
        tests.with-sops.module = ./tests;
        tests.without-sops.module = pkgs.nixosTests.rosenpass;
      };
    };
  };
}
