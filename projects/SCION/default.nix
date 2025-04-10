{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "SCION is a clean-slate Next-Generation Internet (NGI) architecture which offers a.o. multi-path and path-awareness capabilities by design.";
    subgrants = [
      "SCION-proxy"
      "SCION-router-codealignment"
      "Verified-SCION-router"
      "SCION-Rains"
      "SCION-Swarm"
      "SCION-IPFS"
      "SCION-1M"
      "SCION-geo"
    ];
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
        tests.basic = import ./programs/basic/tests/basic.nix args;
      };
    };
  };

  nixos.modules.services = {
    scion = {
      name = "scion";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/scion/scion.nix";
      # TODO: unbreak
      # tests.scion = "${sources.inputs.nixpkgs}/nixos/tests/scion/freestanding-deployment/default.nix";
    };
  };
}
