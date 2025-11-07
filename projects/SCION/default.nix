{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "SCION is a clean-slate Next-Generation Internet (NGI) architecture which offers a.o. multi-path and path-awareness capabilities by design.";
    subgrants = {
      Core = [
        "SCION-1M"
        "SCION-IPFS"
        "SCION-router-codealignment"
        "Verified-SCION-router"
      ];
      Entrust = [
        "SCION-proxy"
      ];
      Review = [
        "SCION-Rains"
        "SCION-Swarm"
        "SCION-geo"
      ];
    };
    links = {
      docs = {
        text = "SCION Documentation";
        url = "https://docs.scion.org/en/latest/";
      };
      build = {
        text = "Build from source";
        url = "https://github.com/scionproto/scion?tab=readme-ov-file#build-from-sources";
      };
      tests = {
        text = "Testing Tutorial";
        url = "https://docs.scion.org/en/latest/tutorials/deploy.html#tasks-to-perform";
      };
    };
  };

  nixos.modules.programs = {
    scion = {
      name = "scion";
      module = ./programs/basic/module.nix;
      examples.basic = {
        module = ./programs/basic/examples/basic.nix;
        description = "";
        tests.basic.module = null; # TODO: make a proper test
      };
    };
  };

  nixos.modules.services = {
    scion = {
      name = "scion";
      module = lib.moduleLocFromOptionString "services.scion";
    };
  };

  nixos.tests.scion.module = pkgs.nixosTests.scion-freestanding-deployment;
}
